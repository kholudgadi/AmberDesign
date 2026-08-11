import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { authenticate } from "../middleware/auth.js";
import type { AuthRequest } from "../types.js";
import { ApiError, asyncHandler, pageSize, parse } from "../utils.js";

export const socialRouter = Router();
socialRouter.use(authenticate);

const uuid = z.string().uuid();
const cursor = (value: unknown) => value === undefined ? undefined : parse(uuid, value);

socialRouter.put("/follows/:userId", asyncHandler(async (req: AuthRequest, res) => {
  const followingId = parse(uuid, req.params.userId);
  if (followingId === req.user!.uid) throw new ApiError(422, "Cannot follow yourself", "INVALID_FOLLOW");
  const target = await prisma.user.findFirst({ where: { id: followingId, disabled: false }, select: { id: true } });
  if (!target) throw new ApiError(404, "User not found", "NOT_FOUND");
  await prisma.userFollow.upsert({
    where: { followerId_followingId: { followerId: req.user!.uid, followingId } },
    create: { followerId: req.user!.uid, followingId },
    update: {}
  });
  res.status(201).json({ data: { following: true } });
}));

socialRouter.delete("/follows/:userId", asyncHandler(async (req: AuthRequest, res) => {
  const followingId = parse(uuid, req.params.userId);
  await prisma.userFollow.deleteMany({ where: { followerId: req.user!.uid, followingId } });
  res.status(204).send();
}));

socialRouter.get("/follows", asyncHandler(async (req: AuthRequest, res) => {
  const direction = req.query.direction === "followers" ? "followers" : "following";
  const limit = pageSize(req.query.limit);
  const after = cursor(req.query.cursor);
  const userSelect = { id: true, displayName: true, avatarUrl: true, role: true, verified: true } as const;
  if (direction === "followers") {
    const rows = await prisma.userFollow.findMany({
      where: { followingId: req.user!.uid }, include: { follower: { select: userSelect } },
      orderBy: [{ createdAt: "desc" }, { followerId: "desc" }],
      ...(after ? { cursor: { followerId_followingId: { followerId: after, followingId: req.user!.uid } }, skip: 1 } : {}),
      take: limit + 1
    });
    const page = rows.slice(0, limit);
    res.json({ data: page.map(row => row.follower), meta: { hasMore: rows.length > limit, nextCursor: rows.length > limit ? page.at(-1)?.followerId ?? null : null } });
    return;
  }
  const rows = await prisma.userFollow.findMany({
    where: { followerId: req.user!.uid }, include: { following: { select: userSelect } },
    orderBy: [{ createdAt: "desc" }, { followingId: "desc" }],
    ...(after ? { cursor: { followerId_followingId: { followerId: req.user!.uid, followingId: after } }, skip: 1 } : {}),
    take: limit + 1
  });
  const page = rows.slice(0, limit);
  res.json({ data: page.map(row => row.following), meta: { hasMore: rows.length > limit, nextCursor: rows.length > limit ? page.at(-1)?.followingId ?? null : null } });
}));

socialRouter.post("/reports", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({
    targetType: z.enum(["user", "designer", "item", "post", "message"]),
    targetId: uuid,
    reason: z.enum(["spam", "fraud", "harassment", "inappropriate", "copyright", "other"]),
    details: z.string().trim().min(3).max(1500).optional()
  }).strict(), req.body);
  if ((input.targetType === "user" || input.targetType === "designer") && input.targetId === req.user!.uid) {
    throw new ApiError(422, "Cannot report yourself", "INVALID_REPORT");
  }
  const exists = input.targetType === "user" || input.targetType === "designer"
    ? await prisma.user.findUnique({ where: { id: input.targetId }, select: { id: true } })
    : input.targetType === "item"
      ? await prisma.catalogItem.findUnique({ where: { id: input.targetId }, select: { id: true } })
      : input.targetType === "post"
        ? await prisma.post.findUnique({ where: { id: input.targetId }, select: { id: true } })
        : await prisma.message.findUnique({ where: { id: input.targetId }, select: { id: true } });
  if (!exists) throw new ApiError(404, "Report target not found", "NOT_FOUND");
  const report = await prisma.report.upsert({
    where: { reporterId_targetType_targetId: { reporterId: req.user!.uid, targetType: input.targetType, targetId: input.targetId } },
    create: { reporterId: req.user!.uid, ...input },
    update: { reason: input.reason, details: input.details, status: "open" }
  });
  res.status(201).json({ data: { id: report.id, status: report.status } });
}));
