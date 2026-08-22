import { createHash, randomBytes } from "node:crypto";
import bcrypt from "bcryptjs";
import { Router } from "express";
import jwt, { type SignOptions } from "jsonwebtoken";
import { z } from "zod";
import { env } from "../config.js";
import { prisma } from "../database.js";
import { firebaseAuth } from "../firebase.js";
import { authenticate } from "../middleware/auth.js";
import type { AuthRequest, Role } from "../types.js";
import { ApiError, asyncHandler, parse } from "../utils.js";

export const authRouter = Router();
const publicUser = (user: { id: string; email: string | null; phone: string | null; displayName: string | null; role: Role; language: string; verified: boolean }) => user;
const hashToken = (token: string) => createHash("sha256").update(token).digest("hex");

async function issueTokens(user: { id: string; role: Role }) {
  const accessToken = jwt.sign({ role: user.role }, env.JWT_ACCESS_SECRET, {
    subject: user.id,
    expiresIn: env.JWT_ACCESS_TTL as SignOptions["expiresIn"]
  });
  const refreshToken = randomBytes(48).toString("base64url");
  const expiresAt = new Date(Date.now() + env.JWT_REFRESH_DAYS * 86_400_000);
  await prisma.refreshToken.create({ data: { userId: user.id, tokenHash: hashToken(refreshToken), expiresAt } });
  return { accessToken, refreshToken, expiresAt };
}

authRouter.post("/register", asyncHandler(async (req, res) => {
  const input = parse(z.object({
    email: z.string().email(), password: z.string().min(8).max(128),
    displayName: z.string().min(2).max(80), role: z.enum(["customer", "designer", "vendor"]).default("customer"),
    language: z.enum(["ar", "en"]).default("ar"),
    phone: z.string().trim().min(7).max(20).optional(),
    phoneIdToken: z.string().min(100)
  }).strict(), req.body);
  let decoded;
  try {
    // Signature, audience, issuer and expiry are verified by Firebase Admin.
    decoded = await firebaseAuth.verifyIdToken(input.phoneIdToken);
  } catch {
    throw new ApiError(401, "Invalid or expired phone verification", "INVALID_PHONE_VERIFICATION");
  }
  if (!decoded.phone_number || decoded.firebase?.sign_in_provider !== "phone") {
    throw new ApiError(422, "Firebase token does not prove phone ownership", "PHONE_NOT_VERIFIED");
  }
  const phone = decoded.phone_number;
  const firebaseUid = decoded.uid;
  const email = input.email.toLowerCase();
  if (await prisma.user.findUnique({ where: { email } })) throw new ApiError(409, "Email already registered", "EMAIL_EXISTS");
  if (await prisma.user.findFirst({ where: { OR: [{ phone }, { firebaseUid }] } })) throw new ApiError(409, "Phone already registered", "PHONE_EXISTS");
  const user = await prisma.user.create({ data: {
    email, phone, firebaseUid, verified: true,
    passwordHash: await bcrypt.hash(input.password, 12), displayName: input.displayName,
    role: input.role, language: input.language
  } });
  res.status(201).json({ data: { user: publicUser(user), ...(await issueTokens(user)) } });
}));

authRouter.post("/phone/verify", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const { idToken } = parse(z.object({ idToken: z.string().min(100) }).strict(), req.body);
  let decoded;
  try {
    decoded = await firebaseAuth.verifyIdToken(idToken);
  } catch {
    throw new ApiError(401, "Invalid or expired phone verification", "INVALID_PHONE_VERIFICATION");
  }
  const phone = decoded.phone_number;
  if (!phone || decoded.firebase?.sign_in_provider !== "phone") throw new ApiError(422, "Phone was not verified", "PHONE_NOT_VERIFIED");
  const duplicate = await prisma.user.findFirst({ where: { id: { not: req.user!.uid }, OR: [{ phone }, { firebaseUid: decoded.uid }] }, select: { id: true } });
  if (duplicate) throw new ApiError(409, "Phone already registered", "PHONE_EXISTS");
  const user = await prisma.user.update({ where: { id: req.user!.uid }, data: { phone, firebaseUid: decoded.uid, verified: true } });
  res.json({ data: publicUser(user) });
}));

authRouter.post("/login", asyncHandler(async (req, res) => {
  const input = parse(z.object({ email: z.string().email(), password: z.string().min(1).max(128) }), req.body);
  const user = await prisma.user.findUnique({ where: { email: input.email.toLowerCase() } });
  if (!user?.passwordHash || !(await bcrypt.compare(input.password, user.passwordHash))) throw new ApiError(401, "Invalid credentials", "INVALID_CREDENTIALS");
  if (user.disabled) throw new ApiError(403, "Account is disabled", "ACCOUNT_DISABLED");
  res.json({ data: { user: publicUser(user), ...(await issueTokens(user)) } });
}));

authRouter.post("/change-password", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ currentPassword: z.string().min(1).max(128), newPassword: z.string().min(8).max(128) }).strict(), req.body);
  const user = await prisma.user.findUnique({ where: { id: req.user!.uid }, select: { passwordHash: true } });
  if (!user?.passwordHash || !(await bcrypt.compare(input.currentPassword, user.passwordHash))) {
    throw new ApiError(401, "Current password is incorrect", "INVALID_CURRENT_PASSWORD");
  }
  await prisma.$transaction([
    prisma.user.update({ where: { id: req.user!.uid }, data: { passwordHash: await bcrypt.hash(input.newPassword, 12) } }),
    prisma.refreshToken.updateMany({ where: { userId: req.user!.uid, revokedAt: null }, data: { revokedAt: new Date() } })
  ]);
  res.json({ data: { success: true } });
}));

authRouter.post("/refresh", asyncHandler(async (req, res) => {
  const { refreshToken } = parse(z.object({ refreshToken: z.string().min(40) }), req.body);
  const stored = await prisma.refreshToken.findUnique({ where: { tokenHash: hashToken(refreshToken) }, include: { user: true } });
  if (!stored || stored.revokedAt || stored.expiresAt <= new Date() || stored.user.disabled) throw new ApiError(401, "Invalid refresh token", "INVALID_REFRESH_TOKEN");
  const tokens = await prisma.$transaction(async tx => {
    await tx.refreshToken.update({ where: { id: stored.id }, data: { revokedAt: new Date() } });
    const accessToken = jwt.sign({ role: stored.user.role }, env.JWT_ACCESS_SECRET, { subject: stored.user.id, expiresIn: env.JWT_ACCESS_TTL as SignOptions["expiresIn"] });
    const newRefreshToken = randomBytes(48).toString("base64url");
    const expiresAt = new Date(Date.now() + env.JWT_REFRESH_DAYS * 86_400_000);
    await tx.refreshToken.create({ data: { userId: stored.user.id, tokenHash: hashToken(newRefreshToken), expiresAt } });
    return { accessToken, refreshToken: newRefreshToken, expiresAt };
  });
  res.json({ data: tokens });
}));

authRouter.post("/logout", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ refreshToken: z.string().min(40) }), req.body);
  await prisma.refreshToken.updateMany({ where: { userId: req.user!.uid, tokenHash: hashToken(input.refreshToken), revokedAt: null }, data: { revokedAt: new Date() } });
  res.status(204).send();
}));

authRouter.get("/me", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const user = await prisma.user.findUniqueOrThrow({ where: { id: req.user!.uid } });
  const { passwordHash: _, ...safe } = user;
  res.json({ data: safe });
}));
