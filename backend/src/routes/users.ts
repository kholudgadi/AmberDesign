import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, parse } from "../utils.js";

export const usersRouter = Router();
usersRouter.use(authenticate);

usersRouter.patch("/me", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({
    displayName: z.string().min(2).max(80).optional(), bio: z.string().max(1000).optional(),
    avatarUrl: z.string().url().optional(), language: z.enum(["ar", "en"]).optional(),
    city: z.string().max(80).optional(), preferences: z.record(z.unknown()).optional(),
    fcmTokens: z.array(z.string().min(10)).max(10).optional()
  }).strict(), req.body);
  const preferences = input.preferences === undefined ? undefined : JSON.parse(JSON.stringify(input.preferences));
  const user = await prisma.user.update({ where: { id: req.user!.uid }, data: { ...input, preferences, profileComplete: true } });
  const { passwordHash: _, ...safe } = user;
  res.json({ data: safe });
}));

usersRouter.get("/me/favorites", asyncHandler(async (req: AuthRequest, res) => {
  const favorites = await prisma.favorite.findMany({ where: { userId: req.user!.uid }, include: { item: true }, orderBy: { createdAt: "desc" } });
  res.json({ data: favorites.map(f => ({ ...f.item, price: f.item.priceHalalas / 100, favoritedAt: f.createdAt })) });
}));

usersRouter.put("/me/favorites/:targetId", asyncHandler(async (req: AuthRequest, res) => {
  const item = await prisma.catalogItem.findUnique({ where: { id: req.params.targetId } });
  if (!item) throw new ApiError(404, "Item not found", "NOT_FOUND");
  await prisma.favorite.upsert({ where: { userId_itemId: { userId: req.user!.uid, itemId: item.id } }, create: { userId: req.user!.uid, itemId: item.id }, update: {} });
  res.status(201).json({ data: { success: true } });
}));

usersRouter.delete("/me/favorites/:targetId", asyncHandler(async (req: AuthRequest, res) => {
  await prisma.favorite.deleteMany({ where: { userId: req.user!.uid, itemId: req.params.targetId } });
  res.status(204).send();
}));

usersRouter.get("/:id", asyncHandler(async (req, res) => {
  const user = await prisma.user.findUnique({ where: { id: req.params.id }, select: { id: true, displayName: true, bio: true, avatarUrl: true, city: true, role: true, verified: true, createdAt: true } });
  if (!user) throw new ApiError(404, "User not found", "NOT_FOUND");
  res.json({ data: user });
}));
