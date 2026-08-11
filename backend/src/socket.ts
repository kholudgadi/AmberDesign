import type { Server as HttpServer } from "node:http";
import jwt from "jsonwebtoken";
import { Server } from "socket.io";
import { env } from "./config.js";
import { prisma } from "./database.js";

let io: Server | undefined;

export function configureSocket(server: HttpServer) {
  io = new Server(server, { cors: { origin: env.corsOrigins, credentials: true } });
  io.use(async (socket, next) => {
    try {
      const raw = socket.handshake.auth.token ?? socket.handshake.headers.authorization?.replace(/^Bearer /, "");
      const decoded = jwt.verify(String(raw ?? ""), env.JWT_ACCESS_SECRET) as { sub?: string };
      if (!decoded.sub) throw new Error("missing subject");
      const user = await prisma.user.findFirst({ where: { id: decoded.sub, disabled: false }, select: { id: true } });
      if (!user) throw new Error("user unavailable");
      socket.data.userId = user.id;
      next();
    } catch { next(new Error("unauthorized")); }
  });
  io.on("connection", socket => {
    socket.join(`user:${socket.data.userId}`);
    socket.on("conversation:join", async (conversationId: string, acknowledge?: (value: { ok: boolean }) => void) => {
      const member = await prisma.conversationParticipant.findUnique({ where: { conversationId_userId: { conversationId, userId: socket.data.userId } } });
      if (member) socket.join(`conversation:${conversationId}`);
      acknowledge?.({ ok: Boolean(member) });
    });
    socket.on("conversation:leave", (conversationId: string) => socket.leave(`conversation:${conversationId}`));
    socket.on("order:join", async (orderId: string, acknowledge?: (value: { ok: boolean }) => void) => {
      const order = await prisma.order.findUnique({ where: { id: orderId }, include: { lines: { select: { ownerId: true } } } });
      const allowed = Boolean(order && (order.customerId === socket.data.userId || order.lines.some(line => line.ownerId === socket.data.userId)));
      if (allowed) socket.join(`order:${orderId}`);
      acknowledge?.({ ok: allowed });
    });
    socket.on("order:leave", (orderId: string) => socket.leave(`order:${orderId}`));
  });
  return io;
}

export function getIo() {
  if (!io) throw new Error("Socket.io has not been initialized");
  return io;
}
