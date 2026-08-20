import { randomUUID } from "node:crypto";
import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { bucket } from "../firebase.js";
import { authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const platformRouter = Router();
platformRouter.get("/pages/:slug", asyncHandler(async (req, res) => {
  const page = await prisma.page.findFirst({ where: { slug: req.params.slug, published: true } });
  if (!page) throw new ApiError(404, "Page not found", "NOT_FOUND"); res.json({ data: page });
}));
platformRouter.get("/trends", asyncHandler(async (req, res) => res.json({ data: await prisma.trend.findMany({ where: { active: true }, orderBy: { startsAt: "desc" }, take: pageSize(req.query.limit) }) })));
platformRouter.get("/challenges", asyncHandler(async (_req, res) => res.json({ data: await prisma.challenge.findMany({ where: { active: true }, orderBy: { endsAt: "asc" } }) })));
platformRouter.post("/challenges/:id/join", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const { postId } = parse(z.object({ postId: z.string().uuid() }), req.body);
  const [challenge, post] = await Promise.all([prisma.challenge.findFirst({ where: { id: req.params.id, active: true, endsAt: { gt: new Date() } } }), prisma.post.findFirst({ where: { id: postId, authorId: req.user!.uid } })]);
  if (!challenge || !post) throw new ApiError(422, "Invalid challenge entry", "INVALID_ENTRY");
  await prisma.challengeEntry.upsert({ where: { challengeId_userId: { challengeId: challenge.id, userId: req.user!.uid } }, create: { challengeId: challenge.id, userId: req.user!.uid, postId }, update: { postId, status: "submitted" } });
  res.status(201).json({ data: { success: true } });
}));
platformRouter.post("/activity", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ event: z.string().min(1).max(80), targetType: z.string().max(50).optional(), targetId: z.string().max(150).optional(), metadata: z.record(z.unknown()).optional() }), req.body);
  const metadata = input.metadata === undefined ? undefined : JSON.parse(JSON.stringify(input.metadata));
  await prisma.activityEvent.create({ data: { ...input, metadata, userId: req.user!.uid } }); res.status(202).json({ data: { accepted: true } });
}));
platformRouter.post("/uploads/sign", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ contentType: z.enum(["image/jpeg", "image/png", "image/webp", "video/mp4", "application/pdf"]), extension: z.enum(["jpg", "jpeg", "png", "webp", "mp4", "pdf"]) }), req.body);
  const path = `users/${req.user!.uid}/uploads/${randomUUID()}.${input.extension}`;
  const [url] = await bucket.file(path).getSignedUrl({ version: "v4", action: "write", expires: Date.now() + 15 * 60 * 1000, contentType: input.contentType });
  res.json({ data: { uploadUrl: url, path, expiresInSeconds: 900 } });
}));
platformRouter.post("/uploads/confirm", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ path: z.string().min(1).max(300) }).strict(), req.body);
  if (!input.path.startsWith(`users/${req.user!.uid}/uploads/`)) {
    throw new ApiError(403, "Cannot confirm a file outside your own uploads", "FORBIDDEN");
  }
  const file = bucket.file(input.path);
  const [exists] = await file.exists();
  if (!exists) throw new ApiError(404, "Uploaded file not found", "NOT_FOUND");
  await file.makePublic();
  res.json({ data: { url: `https://storage.googleapis.com/${bucket.name}/${input.path}` } });
}));
platformRouter.post("/ai/taste-analysis", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ domain: z.enum(["fashion", "interior"]), imageUrls: z.array(z.string().url()).min(1).max(5), answers: z.record(z.string()).default({}) }), req.body);
  const job = await prisma.aiJob.create({ data: { ...input, answers: input.answers ?? {}, userId: req.user!.uid, type: "taste_analysis" } }); res.status(202).json({ data: job });
}));
platformRouter.get("/ai/jobs/:id", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const job = await prisma.aiJob.findFirst({ where: { id: req.params.id, ...(req.user!.role === "admin" ? {} : { userId: req.user!.uid }) } });
  if (!job) throw new ApiError(404, "AI job not found", "NOT_FOUND"); res.json({ data: job });
}));

platformRouter.get("/notifications", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const notifications = await prisma.notification.findMany({ where: { userId: req.user!.uid }, orderBy: { createdAt: "desc" }, take: pageSize(req.query.limit, 100) });
  res.json({ data: notifications });
}));

platformRouter.post("/notifications/:id/read", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const updated = await prisma.notification.updateMany({ where: { id: req.params.id, userId: req.user!.uid, readAt: null }, data: { readAt: new Date() } });
  if (!updated.count) throw new ApiError(404, "Unread notification not found", "NOT_FOUND");
  res.json({ data: { success: true } });
}));
