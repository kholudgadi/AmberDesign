import cors from "cors";
import express from "express";
import rateLimit from "express-rate-limit";
import helmet from "helmet";
import morgan from "morgan";
import { env } from "./config.js";
import { prisma } from "./database.js";
import { asyncHandler, errorHandler } from "./utils.js";
import { adminRouter } from "./routes/admin.js";
import { authRouter } from "./routes/auth.js";
import { catalogRouter } from "./routes/catalog.js";
import { chatRouter } from "./routes/chat.js";
import { communityRouter } from "./routes/community.js";
import { designersRouter } from "./routes/designers.js";
import { ordersRouter } from "./routes/orders.js";
import { platformRouter } from "./routes/platform.js";
import { supportRouter } from "./routes/support.js";
import { usersRouter } from "./routes/users.js";
import { socialRouter } from "./routes/social.js";

export const app = express();
app.set("trust proxy", 1);
app.use(helmet());
app.use(cors({ origin(origin, callback) {
  const isLocalDevelopmentOrigin = env.NODE_ENV !== "production" && origin != null && (() => {
    try {
      const url = new URL(origin);
      return (url.hostname === "localhost" || url.hostname === "127.0.0.1") && (url.protocol === "http:" || url.protocol === "https:");
    } catch { return false; }
  })();
  if (!origin || env.corsOrigins.includes(origin) || isLocalDevelopmentOrigin) return callback(null, true);
  callback(new Error("Origin not allowed"));
}, credentials: true }));
app.use(express.json({ limit: "2mb" }));
app.use(morgan(env.NODE_ENV === "production" ? "combined" : "dev"));
app.use(rateLimit({ windowMs: 60_000, limit: 120, standardHeaders: "draft-7", legacyHeaders: false }));

app.get("/health", asyncHandler(async (_req, res) => {
  await prisma.$queryRaw`SELECT 1`;
  res.json({ status: "ok", database: "connected", service: "amberdesign-api", timestamp: new Date().toISOString() });
}));
app.use("/api/v1/auth", authRouter);
app.use("/api/v1/users", usersRouter);
app.use("/api/v1/social", socialRouter);
app.use("/api/v1/catalog", catalogRouter);
app.use("/api/v1/orders", ordersRouter);
app.use("/api/v1/community", communityRouter);
app.use("/api/v1/designers", designersRouter);
app.use("/api/v1/chat", chatRouter);
app.use("/api/v1/support", supportRouter);
app.use("/api/v1/admin", adminRouter);
app.use("/api/v1", platformRouter);
app.use((_req, res) => res.status(404).json({ error: { code: "NOT_FOUND", message: "Route not found" } }));
app.use(errorHandler);
