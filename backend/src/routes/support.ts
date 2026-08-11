import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { allow, authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const supportRouter = Router();
supportRouter.use(authenticate);
supportRouter.post("/tickets", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ subject: z.string().min(3).max(150), category: z.enum(["order", "payment", "account", "content", "other"]), message: z.string().min(5).max(5000), orderId: z.string().uuid().optional() }), req.body);
  const ticket = await prisma.ticket.create({ data: { userId: req.user!.uid, subject: input.subject, category: input.category, orderId: input.orderId, messages: { create: { senderId: req.user!.uid, text: input.message } } } });
  res.status(201).json({ data: ticket });
}));
supportRouter.get("/tickets", asyncHandler(async (req: AuthRequest, res) => {
  const staff = ["admin", "moderator"].includes(req.user!.role);
  const tickets = await prisma.ticket.findMany({ where: staff ? {} : { userId: req.user!.uid }, orderBy: { updatedAt: "desc" }, take: pageSize(req.query.limit) });
  res.json({ data: tickets });
}));
supportRouter.post("/tickets/:id/messages", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ text: z.string().min(1).max(5000), internal: z.boolean().default(false) }), req.body);
  const ticket = await prisma.ticket.findUnique({ where: { id: req.params.id } });
  if (!ticket) throw new ApiError(404, "Ticket not found", "NOT_FOUND");
  const staff = ["admin", "moderator"].includes(req.user!.role);
  if (!staff && ticket.userId !== req.user!.uid) throw new ApiError(403, "Cannot access ticket", "FORBIDDEN");
  if (!staff && input.internal) throw new ApiError(403, "Internal notes are staff-only", "FORBIDDEN");
  const message = await prisma.ticketMessage.create({ data: { ticketId: ticket.id, senderId: req.user!.uid, ...input } });
  await prisma.ticket.update({ where: { id: ticket.id }, data: { status: staff ? "waiting_user" : "open" } });
  res.status(201).json({ data: message });
}));
supportRouter.patch("/tickets/:id", allow("moderator", "admin"), asyncHandler(async (req, res) => {
  const input = parse(z.object({ status: z.enum(["open", "in_progress", "waiting_user", "resolved", "closed"]).optional(), priority: z.enum(["low", "normal", "high", "urgent"]).optional(), assignedTo: z.string().uuid().optional() }), req.body);
  await prisma.ticket.update({ where: { id: req.params.id }, data: input }); res.json({ data: { success: true } });
}));
