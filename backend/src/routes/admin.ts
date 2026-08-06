import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { messaging } from "../firebase.js";
import { allow, authenticate } from "../middleware/auth.js";
import { roles, type AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const adminRouter = Router();
adminRouter.use(authenticate, allow("moderator", "admin"));
adminRouter.get("/dashboard", asyncHandler(async (_req, res) => {
  const [users, catalogItems, orders, openTickets, revenue] = await Promise.all([
    prisma.user.count(), prisma.catalogItem.count(), prisma.order.count(), prisma.ticket.count({ where: { status: { in: ["open", "in_progress"] } } }),
    prisma.order.aggregate({ where: { status: "completed" }, _sum: { totalHalalas: true } })
  ]);
  res.json({ data: { users, catalogItems, orders, openTickets, completedRevenue: (revenue._sum.totalHalalas ?? 0) / 100, currency: "SAR" } });
}));
adminRouter.get("/users", asyncHandler(async (req, res) => {
  const role = roles.includes(req.query.role as typeof roles[number]) ? req.query.role as typeof roles[number] : undefined;
  const users = await prisma.user.findMany({ where: { role }, select: { id: true, displayName: true, email: true, phone: true, role: true, verified: true, disabled: true, createdAt: true }, orderBy: { createdAt: "desc" }, take: pageSize(req.query.limit) });
  res.json({ data: users });
}));
adminRouter.patch("/users/:id", allow("admin"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ role: z.enum(roles).optional(), disabled: z.boolean().optional(), verified: z.boolean().optional() }), req.body);
  if (req.params.id === req.user!.uid && input.disabled) throw new ApiError(422, "Cannot disable your own account", "INVALID_OPERATION");
  await prisma.user.update({ where: { id: req.params.id }, data: input }); res.json({ data: { success: true } });
}));
adminRouter.patch("/catalog/:id/moderation", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ status: z.enum(["approved", "rejected", "hidden"]), reason: z.string().max(500).optional() }), req.body);
  await prisma.catalogItem.update({ where: { id: req.params.id }, data: { moderationStatus: input.status, moderationReason: input.reason, active: input.status === "approved" } });
  res.json({ data: { success: true } });
}));
adminRouter.post("/notifications", allow("admin"), asyncHandler(async (req, res) => {
  const input = parse(z.object({ title: z.string().min(1).max(100), body: z.string().min(1).max(500), topic: z.enum(["all", "customers", "designers", "vendors"]), data: z.record(z.string()).default({}) }), req.body);
  const messageId = await messaging.send({ topic: input.topic, notification: { title: input.title, body: input.body }, data: input.data });
  const campaign = await prisma.notificationCampaign.create({ data: { ...input, data: input.data ?? {}, messageId, status: "sent" } });
  res.status(201).json({ data: campaign });
}));
adminRouter.put("/pages/:slug", allow("admin"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ titleAr: z.string(), titleEn: z.string(), contentAr: z.string(), contentEn: z.string(), published: z.boolean() }), req.body);
  const page = await prisma.page.upsert({ where: { slug: req.params.slug }, create: { slug: req.params.slug, ...input, updatedBy: req.user!.uid }, update: { ...input, updatedBy: req.user!.uid } });
  res.json({ data: page });
}));
