import { Router } from "express";
import { z } from "zod";
import { prisma } from "../database.js";
import { allow, authenticate } from "../middleware/auth.js";
import { getIo } from "../socket.js";
import type { AuthRequest, OrderStatus } from "../types.js";
import { orderStatuses } from "../types.js";
import { ApiError, asyncHandler, pageCursor, pageSize, paginated, parse } from "../utils.js";
import { paymentProvider } from "../services/payments.js";
import { env } from "../config.js";

export const ordersRouter = Router();
ordersRouter.use(authenticate);
const transitions: Record<OrderStatus, OrderStatus[]> = {
  pending_payment: ["confirmed", "cancelled"], confirmed: ["accepted", "cancelled"], accepted: ["in_progress", "cancelled"],
  in_progress: ["ready", "cancelled"], ready: ["shipped", "completed"], shipped: ["completed"], completed: ["refunded"], cancelled: ["refunded"], refunded: []
};
const presentOrder = <T extends { subtotalHalalas: number; discountHalalas: number; totalHalalas: number }>(o: T) => ({ ...o, subtotal: o.subtotalHalalas / 100, discount: o.discountHalalas / 100, total: o.totalHalalas / 100 });
const presentDesignRequest = <T extends { serviceFeeHalalas: number; platformFeeHalalas: number; quotedHalalas: number | null }>(request: T) => ({
  ...request,
  kind: "design_request",
  serviceFee: request.serviceFeeHalalas / 100,
  platformFee: request.platformFeeHalalas / 100,
  quotedPrice: request.quotedHalalas === null ? null : request.quotedHalalas / 100
});

ordersRouter.post("/design-requests", allow("customer"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({
    category: z.enum(["fashion", "interior"]),
    title: z.string().trim().min(2).max(150),
    specifications: z.record(z.string(), z.string().max(500)),
    details: z.string().trim().max(2000).optional(),
    referenceUrls: z.array(z.string().url()).max(10).default([]),
    serviceFee: z.number().nonnegative().max(1_000_000).default(0),
    platformFee: z.number().nonnegative().max(1_000_000).default(0)
  }).strict(), req.body);
  const { serviceFee, platformFee, ...data } = input;
  const request = await prisma.designRequest.create({ data: {
    ...data,
    specifications: JSON.parse(JSON.stringify(data.specifications)),
    customerId: req.user!.uid,
    serviceFeeHalalas: Math.round((serviceFee ?? 0) * 100),
    platformFeeHalalas: Math.round((platformFee ?? 0) * 100)
  } });
  res.status(201).json({ data: presentDesignRequest(request) });
}));

ordersRouter.get("/design-requests", asyncHandler(async (req: AuthRequest, res) => {
  const limit = pageSize(req.query.limit);
  const cursor = pageCursor(req.query.cursor);
  const where = req.user!.role === "customer"
    ? { customerId: req.user!.uid }
    : req.user!.role === "designer"
      ? { assignedDesignerId: req.user!.uid }
      : {};
  const rows = await prisma.designRequest.findMany({
    where,
    include: {
      assignedDesigner: { select: { id: true, displayName: true, avatarUrl: true } },
      customer: { select: { id: true, displayName: true, avatarUrl: true, city: true } }
    },
    orderBy: [{ createdAt: "desc" }, { id: "desc" }],
    ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    take: limit + 1
  });
  const page = paginated(rows, limit);
  res.json({ data: page.data.map(presentDesignRequest), meta: page.meta });
}));

ordersRouter.get("/design-requests-available", allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const limit = pageSize(req.query.limit);
  const cursor = pageCursor(req.query.cursor);
  const rows = await prisma.designRequest.findMany({
    where: { assignedDesignerId: null, status: "submitted" },
    include: { customer: { select: { id: true, displayName: true, avatarUrl: true, city: true } } },
    orderBy: [{ createdAt: "asc" }, { id: "asc" }],
    ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}),
    take: limit + 1
  });
  const page = paginated(rows, limit);
  res.json({ data: page.data.map(presentDesignRequest), meta: page.meta });
}));

ordersRouter.post("/design-requests/:id/claim", allow("designer"), asyncHandler(async (req: AuthRequest, res) => {
  const result = await prisma.$transaction(async tx => {
    const claimed = await tx.designRequest.updateMany({
      where: { id: req.params.id, assignedDesignerId: null, status: "submitted" },
      data: { assignedDesignerId: req.user!.uid, status: "assigned" }
    });
    if (!claimed.count) throw new ApiError(409, "Design request is no longer available", "REQUEST_ALREADY_CLAIMED");
    const request = await tx.designRequest.findUniqueOrThrow({ where: { id: req.params.id } });
    const participants = [request.customerId, req.user!.uid].sort();
    const key = `${participants.join(":")}:design-request:${request.id}`;
    const conversation = await tx.conversation.upsert({
      where: { key }, update: {},
      create: { key, designRequestId: request.id, participants: { create: participants.map(userId => ({ userId })) } }
    });
    await tx.notification.create({ data: {
      userId: request.customerId, type: "design_request_assigned",
      titleAr: "تم تعيين مصمم لطلبك", titleEn: "A designer was assigned",
      bodyAr: "يمكنك الآن التواصل مع المصمم عبر المحادثة", bodyEn: "You can now chat with your designer",
      data: { designRequestId: request.id, designerId: req.user!.uid, conversationId: conversation.id }
    } });
    return { request, conversationId: conversation.id };
  });
  getIo().to(`user:${result.request.customerId}`).emit("design-request:assigned", result);
  res.json({ data: { ...presentDesignRequest(result.request), conversationId: result.conversationId } });
}));

ordersRouter.get("/design-requests/:id", asyncHandler(async (req: AuthRequest, res) => {
  const request = await prisma.designRequest.findUnique({
    where: { id: req.params.id },
    include: {
      assignedDesigner: { select: { id: true, displayName: true, avatarUrl: true } },
      customer: { select: { id: true, displayName: true, avatarUrl: true, city: true } }
    }
  });
  if (!request) throw new ApiError(404, "Design request not found", "NOT_FOUND");
  if (![request.customerId, request.assignedDesignerId].includes(req.user!.uid) && !["admin", "moderator"].includes(req.user!.role)) {
    throw new ApiError(403, "Cannot view this design request", "FORBIDDEN");
  }
  res.json({ data: presentDesignRequest(request) });
}));

ordersRouter.post("/", asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({
    lines: z.array(z.object({ itemId: z.string().uuid(), quantity: z.number().int().min(1).max(20), selectedOptions: z.record(z.string()).optional() })).min(1).max(30),
    address: z.object({ name: z.string().min(2), phone: z.string().min(7), city: z.string().min(2), line1: z.string().min(3), postalCode: z.string().optional() }), notes: z.string().max(1000).optional()
  }), req.body);
  if (new Set(input.lines.map(l => l.itemId)).size !== input.lines.length) throw new ApiError(422, "Duplicate order lines are not allowed", "DUPLICATE_LINES");
  const order = await prisma.$transaction(async tx => {
    const items = await tx.catalogItem.findMany({ where: { id: { in: input.lines.map(l => l.itemId) }, active: true, moderationStatus: "approved" } });
    if (items.length !== input.lines.length) throw new ApiError(422, "One or more items are unavailable", "ITEM_UNAVAILABLE");
    const lines = input.lines.map(line => {
      const item = items.find(i => i.id === line.itemId)!;
      if (item.stock !== null && item.stock < line.quantity) throw new ApiError(409, `Insufficient stock: ${item.id}`, "INSUFFICIENT_STOCK");
      return { item, line, totalHalalas: item.priceHalalas * line.quantity };
    });
    for (const { item, line } of lines) {
      if (item.stock !== null) {
        const updated = await tx.catalogItem.updateMany({ where: { id: item.id, stock: { gte: line.quantity } }, data: { stock: { decrement: line.quantity } } });
        if (updated.count !== 1) throw new ApiError(409, `Insufficient stock: ${item.id}`, "INSUFFICIENT_STOCK");
      }
    }
    const subtotalHalalas = lines.reduce((sum, l) => sum + l.totalHalalas, 0);
    return tx.order.create({ data: {
      customerId: req.user!.uid, address: input.address, notes: input.notes, subtotalHalalas, totalHalalas: subtotalHalalas,
      lines: { create: lines.map(({ item, line, totalHalalas }) => ({ itemId: item.id, ownerId: item.ownerId, quantity: line.quantity, selectedOptions: line.selectedOptions, titleAr: item.titleAr, titleEn: item.titleEn, unitPriceHalalas: item.priceHalalas, totalHalalas })) },
      history: { create: { status: "pending_payment", actorId: req.user!.uid } }
    }, include: { lines: true } });
  }, { isolationLevel: "Serializable" });
  res.status(201).json({ data: presentOrder(order) });
}));

ordersRouter.get("/", asyncHandler(async (req: AuthRequest, res) => {
  const status = orderStatuses.includes(req.query.status as OrderStatus) ? req.query.status as OrderStatus : undefined;
  const limit = pageSize(req.query.limit);
  const cursor = pageCursor(req.query.cursor);
  const where = req.user!.role === "customer" ? { customerId: req.user!.uid, status } : ["designer", "vendor"].includes(req.user!.role) ? { status, lines: { some: { ownerId: req.user!.uid } } } : { status };
  const orders = await prisma.order.findMany({ where, include: { lines: true }, orderBy: [{ createdAt: "desc" }, { id: "desc" }], ...(cursor ? { cursor: { id: cursor }, skip: 1 } : {}), take: limit + 1 });
  const page = paginated(orders, limit);
  res.json({ data: page.data.map(presentOrder), meta: page.meta });
}));

ordersRouter.get("/:id", asyncHandler(async (req: AuthRequest, res) => {
  const order = await prisma.order.findUnique({ where: { id: req.params.id }, include: { lines: true, history: { orderBy: { createdAt: "asc" } } } });
  if (!order) throw new ApiError(404, "Order not found", "NOT_FOUND");
  const permitted = req.user!.role === "admin" || req.user!.role === "moderator" || order.customerId === req.user!.uid || order.lines.some(l => l.ownerId === req.user!.uid);
  if (!permitted) throw new ApiError(403, "Cannot view this order", "FORBIDDEN");
  res.json({ data: presentOrder(order) });
}));

ordersRouter.patch("/:id/status", allow("designer", "vendor", "moderator", "admin"), asyncHandler(async (req: AuthRequest, res) => {
  const input = parse(z.object({ status: z.enum(orderStatuses), note: z.string().max(500).optional() }), req.body);
  const changed = await prisma.$transaction(async tx => {
    const order = await tx.order.findUnique({ where: { id: req.params.id }, include: { lines: true } });
    if (!order) throw new ApiError(404, "Order not found", "NOT_FOUND");
    if (!["admin", "moderator"].includes(req.user!.role) && !order.lines.some(l => l.ownerId === req.user!.uid)) throw new ApiError(403, "Cannot update this order", "FORBIDDEN");
    if (!transitions[order.status]?.includes(input.status)) throw new ApiError(409, `Invalid transition: ${order.status} -> ${input.status}`, "INVALID_STATUS_TRANSITION");
    await tx.order.update({ where: { id: order.id }, data: { status: input.status, history: { create: { status: input.status, previousStatus: order.status, note: input.note, actorId: req.user!.uid } } } });
    const notification = await tx.notification.create({ data: {
      userId: order.customerId, type: "order_status", titleAr: "تحديث حالة الطلب", titleEn: "Order status updated",
      bodyAr: `تم تحديث حالة طلبك إلى ${input.status}`, bodyEn: `Your order status is now ${input.status}`,
      data: { orderId: order.id, status: input.status, previousStatus: order.status }
    } });
    return { orderId: order.id, customerId: order.customerId, status: input.status, previousStatus: order.status, notification };
  });
  getIo().to(`user:${changed.customerId}`).emit("order:status", changed);
  getIo().to(`order:${changed.orderId}`).emit("order:status", changed);
  res.json({ data: { success: true, status: input.status } });
}));

ordersRouter.post("/:id/cancel", asyncHandler(async (req: AuthRequest, res) => {
  const { reason } = parse(z.object({ reason: z.string().min(3).max(500) }), req.body);
  await prisma.$transaction(async tx => {
    const order = await tx.order.findUnique({ where: { id: req.params.id }, include: { lines: true } });
    if (!order) throw new ApiError(404, "Order not found", "NOT_FOUND");
    if (order.customerId !== req.user!.uid && req.user!.role !== "admin") throw new ApiError(403, "Cannot cancel this order", "FORBIDDEN");
    if (!["pending_payment", "confirmed", "accepted"].includes(order.status)) throw new ApiError(409, "Order can no longer be cancelled", "CANCELLATION_NOT_ALLOWED");
    for (const line of order.lines) await tx.catalogItem.updateMany({ where: { id: line.itemId, stock: { not: null } }, data: { stock: { increment: line.quantity } } });
    await tx.order.update({ where: { id: order.id }, data: { status: "cancelled", cancellationReason: reason, history: { create: { status: "cancelled", previousStatus: order.status, note: reason, actorId: req.user!.uid } } } });
  }, { isolationLevel: "Serializable" });
  res.json({ data: { success: true } });
}));

ordersRouter.post("/:id/payment-intent", asyncHandler(async (req: AuthRequest, res) => {
  const order = await prisma.order.findFirst({ where: { id: req.params.id, customerId: req.user!.uid }, include: { payments: true } });
  if (!order) throw new ApiError(404, "Order not found", "NOT_FOUND");
  if (order.status !== "pending_payment") throw new ApiError(409, "Order is not awaiting payment", "ORDER_NOT_PAYABLE");
  if (order.payments.some(payment => payment.status === "paid")) throw new ApiError(409, "Order is already paid", "ALREADY_PAID");
  if (order.payments.some(payment => payment.status === "initiated")) throw new ApiError(409, "A payment attempt is already in progress", "PAYMENT_IN_PROGRESS");
  const invoice = await paymentProvider.createInvoice({ orderId: order.id, amountHalalas: order.totalHalalas, currency: order.currency, description: `AmberDesign order ${order.id}` });
  const payment = await prisma.payment.create({ data: {
    orderId: order.id, userId: req.user!.uid, amountHalalas: order.totalHalalas,
    currency: order.currency, provider: env.PAYMENT_PROVIDER, providerReference: invoice.providerReference, status: "initiated"
  } });
  res.status(201).json({ data: { paymentId: payment.id, provider: payment.provider, amount: payment.amountHalalas / 100, checkoutUrl: invoice.checkoutUrl } });
}));
