import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { allow, authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageCursor, pageSize, paginated, parse } from "../utils.js";

export const catalogRouter = Router();
const itemSchema = z.object({
  type: z.enum(["product", "service"]), titleAr: z.string().min(2).max(150), titleEn: z.string().min(2).max(150),
  descriptionAr: z.string().max(5000), descriptionEn: z.string().max(5000), categoryId: z.string().uuid(),
  price: z.number().nonnegative().max(10_000_000), currency: z.string().length(3).default("SAR"), images: z.array(z.string().url()).min(1).max(12),
  tags: z.array(z.string().max(40)).max(20).default([]), colors: z.array(z.string()).max(20).default([]), styles: z.array(z.string()).max(20).default([]),
  stock: z.number().int().nonnegative().optional(), durationDays: z.number().int().positive().optional()
});
const presentItem = <T extends { priceHalalas: number }>(item: T) => ({ ...item, price: item.priceHalalas / 100, priceHalalas: undefined });

catalogRouter.get("/items", asyncHandler(async (req, res) => {
  const limit = pageSize(req.query.limit);
  const cursor = pageCursor(req.query.cursor);
  const q = String(req.query.q ?? "").trim();
  const items = await prisma.catalogItem.findMany({
    where: { active: true, moderationStatus: "approved", type: req.query.type === "product" || req.query.type === "service" ? req.query.type : undefined,
      categoryId: typeof req.query.categoryId === "string" ? req.query.categoryId : undefined,
      OR: q ? [{ titleAr: { contains: q, mode: "insensitive" } }, { titleEn: { contains: q, mode: "insensitive" } }, { tags: { has: q } }] : undefined },
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    take: limit + 1
  });
  const page = paginated(items, limit);
  res.json({ data: page.data.map(presentItem), meta: page.meta });
}));

catalogRouter.get("/items/:id", asyncHandler(async (req, res) => {
  const item = await prisma.catalogItem.findFirst({ where: { id: req.params.id, active: true, moderationStatus: "approved" }, include: { reviews: true } });
  if (!item) throw new ApiError(404, "Item not found", "NOT_FOUND");
  res.json({ data: presentItem(item) });
}));

catalogRouter.post("/items", authenticate, allow("designer", "vendor", "admin"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(itemSchema, req.body);
  const { price, ...data } = input;
  const item = await prisma.catalogItem.create({ data: { ...data, priceHalalas: Math.round(price * 100), ownerId: req.user!.uid, active: false, moderationStatus: "pending" } });
  res.status(201).json({ data: { id: item.id } });
}));

catalogRouter.patch("/items/:id", authenticate, allow("designer", "vendor", "admin"), asyncHandler(async (req: AuthRequest, res) => {
  const item = await prisma.catalogItem.findUnique({ where: { id: req.params.id } });
  if (!item) throw new ApiError(404, "Item not found", "NOT_FOUND");
  if (req.user!.role !== "admin" && item.ownerId !== req.user!.uid) throw new ApiError(403, "Not the item owner", "FORBIDDEN");
  const input = parse(itemSchema.partial().strict(), req.body);
  const { price, ...data } = input;
  await prisma.catalogItem.update({ where: { id: item.id }, data: { ...data, priceHalalas: price === undefined ? undefined : Math.round(price * 100), active: false, moderationStatus: "pending" } });
  res.json({ data: { success: true } });
}));

catalogRouter.get("/categories", asyncHandler(async (_req, res) => {
  res.json({ data: await prisma.category.findMany({ where: { active: true }, orderBy: { order: "asc" } }) });
}));

catalogRouter.post("/items/:id/reviews", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ rating: z.number().int().min(1).max(5), comment: z.string().max(1500).optional() }), req.body);
  await prisma.$transaction(async tx => {
    if (!await tx.catalogItem.findUnique({ where: { id: req.params.id } })) throw new ApiError(404, "Item not found", "NOT_FOUND");
    await tx.review.upsert({ where: { itemId_userId: { itemId: req.params.id, userId: req.user!.uid } }, create: { itemId: req.params.id, userId: req.user!.uid, ...input }, update: input });
    const rating = await tx.review.aggregate({ where: { itemId: req.params.id }, _avg: { rating: true }, _count: true });
    await tx.catalogItem.update({ where: { id: req.params.id }, data: { ratingAverage: rating._avg.rating ?? 0, ratingCount: rating._count } });
  });
  res.status(201).json({ data: { success: true } });
}));
