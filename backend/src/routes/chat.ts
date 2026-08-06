import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { authenticate } from "../middleware/auth.js";
import { getIo } from "../socket.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const chatRouter = Router();
chatRouter.use(authenticate);

chatRouter.post("/conversations", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ participantId: z.string().uuid(), orderId: z.string().uuid().optional() }), req.body);
  if (input.participantId === req.user!.uid) throw new ApiError(422, "Cannot chat with yourself", "INVALID_PARTICIPANT");
  const participant = await prisma.user.findFirst({ where: { id: input.participantId, disabled: false } });
  if (!participant) throw new ApiError(404, "Participant not found", "NOT_FOUND");
  if (input.orderId) {
    const order = await prisma.order.findUnique({ where: { id: input.orderId }, include: { lines: true } });
    const allowed = order && [req.user!.uid, input.participantId].every(id => id === order.customerId || order.lines.some(l => l.ownerId === id));
    if (!allowed) throw new ApiError(403, "Participants are not related to this order", "FORBIDDEN");
  }
  const participants = [req.user!.uid, input.participantId].sort();
  const key = `${participants.join(":")}:${input.orderId ?? "general"}`;
  const conversation = await prisma.conversation.upsert({ where: { key }, update: {}, create: { key, orderId: input.orderId, participants: { create: participants.map(userId => ({ userId })) } } });
  res.status(201).json({ data: { id: conversation.id } });
}));

chatRouter.get("/conversations", asyncHandler(async (req: AuthRequest, res) => {
  const rows = await prisma.conversation.findMany({ where: { participants: { some: { userId: req.user!.uid } } }, include: { participants: { include: { user: { select: { id: true, displayName: true, avatarUrl: true } } } } }, orderBy: { updatedAt: "desc" }, take: pageSize(req.query.limit) });
  res.json({ data: rows });
}));

chatRouter.get("/conversations/:id/messages", asyncHandler(async (req: AuthRequest, res) => {
  const member = await prisma.conversationParticipant.findUnique({ where: { conversationId_userId: { conversationId: req.params.id, userId: req.user!.uid } } });
  if (!member) throw new ApiError(403, "Not a conversation participant", "FORBIDDEN");
  const messages = await prisma.message.findMany({ where: { conversationId: req.params.id }, orderBy: { createdAt: "desc" }, take: pageSize(req.query.limit, 100) });
  res.json({ data: messages.reverse() });
}));

chatRouter.post("/conversations/:id/messages", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ text: z.string().min(1).max(4000).optional(), mediaUrl: z.string().url().optional(), mediaType: z.enum(["image", "video", "file"]).optional() }).refine(v => v.text || v.mediaUrl, "Message cannot be empty"), req.body);
  const member = await prisma.conversationParticipant.findUnique({ where: { conversationId_userId: { conversationId: req.params.id, userId: req.user!.uid } } });
  if (!member) throw new ApiError(403, "Not a conversation participant", "FORBIDDEN");
  const message = await prisma.$transaction(async tx => {
    const created = await tx.message.create({ data: { ...input, conversationId: req.params.id, senderId: req.user!.uid, readBy: [req.user!.uid] } });
    await tx.conversation.update({ where: { id: req.params.id }, data: { lastMessage: input.text?.slice(0, 150) ?? input.mediaType, lastSenderId: req.user!.uid } });
    return created;
  });
  getIo().to(`conversation:${req.params.id}`).emit("message:new", message);
  res.status(201).json({ data: message });
}));

chatRouter.post("/conversations/:id/read", asyncHandler(async (req: AuthRequest, res) => {
  const member = await prisma.conversationParticipant.findUnique({ where: { conversationId_userId: { conversationId: req.params.id, userId: req.user!.uid } } });
  if (!member) throw new ApiError(403, "Not a conversation participant", "FORBIDDEN");
  const unread = await prisma.message.findMany({ where: { conversationId: req.params.id, NOT: { readBy: { has: req.user!.uid } } }, select: { id: true, readBy: true } });
  await prisma.$transaction(unread.map(m => prisma.message.update({ where: { id: m.id }, data: { readBy: { set: [...m.readBy, req.user!.uid] } } })));
  getIo().to(`conversation:${req.params.id}`).emit("messages:read", { userId: req.user!.uid, messageIds: unread.map(m => m.id) });
  res.json({ data: { updated: unread.length } });
}));
