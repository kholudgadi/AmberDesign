import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const communityRouter = Router();
communityRouter.get("/posts", asyncHandler(async (req, res) => {
  const posts = await prisma.post.findMany({ where: { status: "published" }, include: { author: { select: { id: true, displayName: true, avatarUrl: true } }, _count: { select: { likes: true, comments: true } } }, orderBy: { createdAt: "desc" }, take: pageSize(req.query.limit) });
  res.json({ data: posts });
}));
communityRouter.post("/posts", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ caption: z.string().max(3000), media: z.array(z.object({ type: z.enum(["image", "video"]), url: z.string().url() })).min(1).max(10), tags: z.array(z.string()).max(20).default([]) }), req.body);
  const post = await prisma.post.create({ data: { ...input, authorId: req.user!.uid } });
  res.status(201).json({ data: post });
}));
communityRouter.put("/posts/:id/like", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  if (!await prisma.post.findUnique({ where: { id: req.params.id } })) throw new ApiError(404, "Post not found", "NOT_FOUND");
  await prisma.postLike.upsert({ where: { postId_userId: { postId: req.params.id, userId: req.user!.uid } }, create: { postId: req.params.id, userId: req.user!.uid }, update: {} });
  res.json({ data: { liked: true } });
}));
communityRouter.delete("/posts/:id/like", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  await prisma.postLike.deleteMany({ where: { postId: req.params.id, userId: req.user!.uid } }); res.status(204).send();
}));
communityRouter.get("/posts/:id/comments", asyncHandler(async (req, res) => {
  const comments = await prisma.comment.findMany({ where: { postId: req.params.id, status: "published" }, include: { author: { select: { id: true, displayName: true, avatarUrl: true } } }, orderBy: { createdAt: "asc" }, take: pageSize(req.query.limit) });
  res.json({ data: comments });
}));
communityRouter.post("/posts/:id/comments", authenticate, asyncHandler(async (req: AuthRequest, res) => {
  const { text } = parse(z.object({ text: z.string().min(1).max(1000) }), req.body);
  if (!await prisma.post.findUnique({ where: { id: req.params.id } })) throw new ApiError(404, "Post not found", "NOT_FOUND");
  const comment = await prisma.comment.create({ data: { postId: req.params.id, authorId: req.user!.uid, text } });
  res.status(201).json({ data: comment });
}));
