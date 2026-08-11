import type { NextFunction, Response } from "express";
import jwt from "jsonwebtoken";
import { prisma } from "../database.js";
import { env } from "../config.js";
import type { AuthRequest, Role } from "../types.js";
import { ApiError, asyncHandler } from "../utils.js";

export const authenticate = asyncHandler(async (req: AuthRequest, _res: Response, next: NextFunction) => {
  const header = req.headers.authorization;
  if (!header?.startsWith("Bearer ")) throw new ApiError(401, "Authentication token required", "UNAUTHENTICATED");
  let decoded: { sub?: string };
  try {
    decoded = jwt.verify(header.slice(7), env.JWT_ACCESS_SECRET) as { sub?: string };
  } catch {
    throw new ApiError(401, "Invalid or expired access token", "INVALID_TOKEN");
  }
  if (!decoded.sub) throw new ApiError(401, "Invalid access token", "INVALID_TOKEN");
  const profile = await prisma.user.findUnique({ where: { id: decoded.sub } });
  if (!profile) throw new ApiError(401, "Account not found", "UNAUTHENTICATED");
  if (profile.disabled) throw new ApiError(403, "Account is disabled", "ACCOUNT_DISABLED");
  req.user = { uid: profile.id, email: profile.email ?? undefined, phone: profile.phone ?? undefined, role: profile.role as Role, disabled: profile.disabled };
  next();
});

export const allow = (...allowed: Role[]) => (req: AuthRequest, _res: Response, next: NextFunction) => {
  if (!req.user) return next(new ApiError(401, "Unauthenticated", "UNAUTHENTICATED"));
  if (!allowed.includes(req.user.role)) return next(new ApiError(403, "Insufficient permissions", "FORBIDDEN"));
  next();
};
