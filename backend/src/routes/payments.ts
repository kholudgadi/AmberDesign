import { Router } from "express";
import { prisma } from "../database.js";
import { getIo } from "../socket.js";
import { paymentProvider } from "../services/payments.js";
import { asyncHandler } from "../utils.js";

export const paymentsRouter = Router();

paymentsRouter.post("/webhook", asyncHandler(async (req, res) => {
  let outcome;
  try {
    outcome = paymentProvider.handleWebhook(req.body);
  } catch {
    return res.status(401).json({ error: { code: "INVALID_WEBHOOK", message: "Webhook verification failed" } });
  }
  if (outcome.kind === "ignored" || !outcome.providerReference) {
    return res.json({ data: { received: true, ignored: outcome.reason ?? true } });
  }
  const paymentStatus: "paid" | "failed" | "refunded" = outcome.kind;

  const payment = await prisma.payment.findUnique({
    where: { provider_providerReference: { provider: outcome.provider, providerReference: outcome.providerReference } },
    include: { order: true }
  });
  if (!payment) return res.json({ data: { received: true, matched: false } });
  if (payment.amountHalalas !== outcome.amountHalalas || payment.currency.toUpperCase() !== outcome.currency) {
    console.warn(`Rejected mismatched payment webhook for ${payment.id}`);
    return res.json({ data: { received: true, matched: false, reason: "amount_or_currency_mismatch" } });
  }

  const result = await prisma.$transaction(async tx => {
    const claimed = await tx.payment.updateMany({
      where: { id: payment.id, status: { not: paymentStatus } },
      data: { status: paymentStatus }
    });
    if (!claimed.count) return null;

    let statusChange: { status: string; previousStatus: string } | null = null;
    if (paymentStatus === "paid") {
      const changed = await tx.order.updateMany({ where: { id: payment.orderId, status: "pending_payment" }, data: { status: "confirmed", paymentStatus: "paid" } });
      if (changed.count) {
        await tx.orderStatusHistory.create({ data: { orderId: payment.orderId, status: "confirmed", previousStatus: "pending_payment", note: "Payment confirmed by Moyasar", actorId: payment.userId } });
        statusChange = { status: "confirmed", previousStatus: "pending_payment" };
      }
    } else {
      await tx.order.update({ where: { id: payment.orderId }, data: { paymentStatus } });
    }
    await tx.notification.create({ data: {
      userId: payment.userId,
      type: "payment_status",
      titleAr: paymentStatus === "paid" ? "تم تأكيد الدفع" : paymentStatus === "failed" ? "فشلت عملية الدفع" : "تم استرجاع المبلغ",
      titleEn: paymentStatus === "paid" ? "Payment confirmed" : paymentStatus === "failed" ? "Payment failed" : "Payment refunded",
      bodyAr: `حالة الدفع: ${paymentStatus}`,
      bodyEn: `Payment status: ${paymentStatus}`,
      data: { orderId: payment.orderId, paymentId: payment.id, status: paymentStatus }
    } });
    return { statusChange };
  });

  if (!result) return res.json({ data: { received: true, alreadyProcessed: true } });
  if (result.statusChange) {
    getIo().to(`user:${payment.userId}`).emit("order:status", { orderId: payment.orderId, ...result.statusChange });
    getIo().to(`order:${payment.orderId}`).emit("order:status", { orderId: payment.orderId, ...result.statusChange });
  }
  getIo().to(`user:${payment.userId}`).emit("payment:status", { orderId: payment.orderId, paymentId: payment.id, status: paymentStatus });
  res.json({ data: { received: true } });
}));
