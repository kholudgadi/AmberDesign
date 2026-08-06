import "dotenv/config";
import { z } from "zod";

const schema = z.object({
  NODE_ENV: z.enum(["development", "test", "production"]).default("development"),
  PORT: z.coerce.number().int().positive().default(3000),
  APP_URL: z.string().url().default("http://localhost:3000"),
  CORS_ORIGINS: z.string().default("http://localhost:3000"),
  DATABASE_URL: z.string().min(1),
  JWT_ACCESS_SECRET: z.string().min(32),
  JWT_ACCESS_TTL: z.string().default("15m"),
  JWT_REFRESH_DAYS: z.coerce.number().int().positive().default(30),
  FIREBASE_PROJECT_ID: z.string().min(1).optional(),
  FIREBASE_STORAGE_BUCKET: z.string().optional(),
  FIREBASE_SERVICE_ACCOUNT_JSON: z.string().optional(),
  PAYMENT_PROVIDER: z.enum(["mock", "hyperpay", "moyasar"]).default("mock"),
  PAYMENT_WEBHOOK_SECRET: z.string().min(8).default("replace-me")
});

const parsed = schema.safeParse(process.env);
if (!parsed.success) {
  throw new Error(`Invalid environment: ${parsed.error.issues.map(i => `${i.path.join(".")}: ${i.message}`).join(", ")}`);
}

if (parsed.data.NODE_ENV === "production" && parsed.data.PAYMENT_WEBHOOK_SECRET === "replace-me") {
  throw new Error("PAYMENT_WEBHOOK_SECRET must be changed in production");
}

export const env = {
  ...parsed.data,
  corsOrigins: parsed.data.CORS_ORIGINS.split(",").map(v => v.trim()).filter(Boolean)
};
