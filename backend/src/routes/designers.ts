import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { allow, authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const designersRouter = Router();
const portfolioSchema = z.object({
  titleAr: z.string().min(2).max(150),
  titleEn: z.string().min(2).max(150),
  descriptionAr: z.string().max(3000).optional(),
  descriptionEn: z.string().max(3000).optional(),
  images: z.array(z.string().url()).min(1).max(20),
  category: z.string().max(80).optional(),
  completedAt: z.coerce.date().optional(),
  featured: z.boolean().default(false)
});

designersRouter.get("/me/dashboard", authenticate, allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const [profile, availableRequests, assignedRequests, portfolio, ratings, recentReviews, recentNotifications] = await prisma.$transaction([
    prisma.user.findUniqueOrThrow({ where: { id: req.user!.uid }, select: { id: true, displayName: true, email: true, bio: true, avatarUrl: true, city: true, verified: true, experienceYears: true, specialties: true } }),
    prisma.designRequest.count({ where: { assignedDesignerId: null, status: "submitted" } }),
    prisma.designRequest.groupBy({ by: ["status"], where: { assignedDesignerId: req.user!.uid }, _count: true, orderBy: { status: "asc" } }),
    prisma.portfolioItem.findMany({ where: { designerId: req.user!.uid, active: true }, orderBy: [{ featured: "desc" }, { createdAt: "desc" }], take: 6 }),
    prisma.designerReview.aggregate({ where: { designerId: req.user!.uid }, _avg: { rating: true }, _count: true }),
    prisma.designerReview.findMany({ where: { designerId: req.user!.uid }, include: { customer: { select: { id: true, displayName: true, avatarUrl: true } } }, orderBy: { createdAt: "desc" }, take: 5 }),
    prisma.notification.findMany({ where: { userId: req.user!.uid }, orderBy: { createdAt: "desc" }, take: 5 })
  ]);
  res.json({ data: { profile, availableRequests, assignedRequests: Object.fromEntries(assignedRequests.map(row => [row.status, row._count])), portfolio, ratingAverage: ratings._avg.rating ?? 0, ratingCount: ratings._count, recentReviews, recentNotifications } });
}));

designersRouter.get("/:id", asyncHandler(async (req, res) => {
  const designer = await prisma.user.findFirst({
    where: { id: req.params.id, role: "designer", disabled: false },
    select: { id: true, displayName: true, bio: true, avatarUrl: true, city: true, verified: true, experienceYears: true, specialties: true, createdAt: true }
  });
  if (!designer) throw new ApiError(404, "Designer not found", "NOT_FOUND");
  const ratings = await prisma.designerReview.aggregate({ where: { designerId: designer.id }, _avg: { rating: true }, _count: true });
  res.json({ data: { ...designer, ratingAverage: ratings._avg.rating ?? 0, ratingCount: ratings._count } });
}));

designersRouter.get("/:id/portfolio", asyncHandler(async (req, res) => {
  const items = await prisma.portfolioItem.findMany({ where: { designerId: req.params.id, active: true }, orderBy: [{ featured: "desc" }, { createdAt: "desc" }], take: pageSize(req.query.limit) });
  res.json({ data: items });
}));

designersRouter.get("/:id/reviews", asyncHandler(async (req, res) => {
  const reviews = await prisma.designerReview.findMany({ where: { designerId: req.params.id }, include: { customer: { select: { id: true, displayName: true, avatarUrl: true } } }, orderBy: { createdAt: "desc" }, take: pageSize(req.query.limit) });
  res.json({ data: reviews });
}));

designersRouter.patch("/me/profile", authenticate, allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ experienceYears: z.number().int().min(0).max(80).optional(), specialties: z.array(z.string().min(1).max(80)).max(20).optional() }).strict(), req.body);
  const designer = await prisma.user.update({ where: { id: req.user!.uid }, data: input, select: { id: true, experienceYears: true, specialties: true } });
  res.json({ data: designer });
}));

designersRouter.post("/me/portfolio", authenticate, allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(portfolioSchema, req.body);
  const item = await prisma.portfolioItem.create({ data: { ...input, designerId: req.user!.uid } });
  res.status(201).json({ data: item });
}));

designersRouter.patch("/me/portfolio/:itemId", authenticate, allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(portfolioSchema.partial().strict(), req.body);
  const updated = await prisma.portfolioItem.updateMany({ where: { id: req.params.itemId, designerId: req.user!.uid }, data: input });
  if (!updated.count) throw new ApiError(404, "Portfolio item not found", "NOT_FOUND");
  res.json({ data: { success: true } });
}));

designersRouter.delete("/me/portfolio/:itemId", authenticate, allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const updated = await prisma.portfolioItem.updateMany({ where: { id: req.params.itemId, designerId: req.user!.uid }, data: { active: false } });
  if (!updated.count) throw new ApiError(404, "Portfolio item not found", "NOT_FOUND");
  res.status(204).send();
}));

designersRouter.post("/:id/reviews", authenticate, allow("customer"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ orderId: z.string().uuid(), rating: z.number().int().min(1).max(5), comment: z.string().max(1500).optional() }), req.body);
  const order = await prisma.order.findFirst({ where: { id: input.orderId, customerId: req.user!.uid, status: "completed", lines: { some: { ownerId: req.params.id } } } });
  if (!order) throw new ApiError(403, "A completed order with this designer is required", "REVIEW_NOT_ALLOWED");
  const review = await prisma.designerReview.upsert({ where: { orderId: order.id }, create: { designerId: req.params.id, customerId: req.user!.uid, ...input }, update: { rating: input.rating, comment: input.comment } });
  res.status(201).json({ data: review });
}));
