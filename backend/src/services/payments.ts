import { randomUUID, timingSafeEqual } from "node:crypto";
import { z } from "zod";
import { env } from "../config.js";

export type InvoiceInput = {
  orderId: string;
  amountHalalas: number;
  currency: string;
  description: string;
};

export type PaymentOutcome = {
  kind: "paid" | "failed" | "refunded" | "ignored";
  provider: string;
  providerReference?: string;
  amountHalalas?: number;
  currency?: string;
  reason?: string;
};

export interface PaymentProvider {
  createInvoice(input: InvoiceInput): Promise<{ providerReference: string; checkoutUrl: string }>;
  handleWebhook(payload: unknown): PaymentOutcome;
}

const webhookSchema = z.object({
  id: z.string().min(1),
  type: z.string().min(1),
  secret_token: z.string(),
  data: z.object({
    id: z.string().min(1),
    invoice_id: z.string().nullish(),
    amount: z.number().int().nonnegative(),
    currency: z.string().length(3)
  }).passthrough()
}).passthrough();

const verifySecret = (received: string) => {
  const actual = Buffer.from(received);
  const expected = Buffer.from(env.PAYMENT_WEBHOOK_SECRET);
  if (actual.length !== expected.length || !timingSafeEqual(actual, expected)) throw new Error("Invalid webhook secret");
};

const parseWebhook = (payload: unknown, provider: string): PaymentOutcome => {
  const event = webhookSchema.parse(payload);
  verifySecret(event.secret_token);
  const kinds: Record<string, PaymentOutcome["kind"]> = {
    payment_paid: "paid",
    payment_faild: "failed",
    payment_failed: "failed",
    payment_refunded: "refunded"
  };
  const kind = kinds[event.type];
  if (!kind) return { kind: "ignored", provider, reason: `Unsupported event: ${event.type}` };
  return {
    kind,
    provider,
    providerReference: event.data.invoice_id ?? event.data.id,
    amountHalalas: event.data.amount,
    currency: event.data.currency.toUpperCase()
  };
};

class MockProvider implements PaymentProvider {
  async createInvoice(input: InvoiceInput) {
    const providerReference = `mock_${randomUUID()}`;
    return { providerReference, checkoutUrl: `${env.APP_URL}/mock-checkout/${input.orderId}` };
  }
  handleWebhook(payload: unknown) { return parseWebhook(payload, "mock"); }
}

class MoyasarProvider implements PaymentProvider {
  async createInvoice(input: InvoiceInput) {
    const authorization = Buffer.from(`${env.MOYASAR_SECRET_KEY}:`).toString("base64");
    const response = await fetch(`${env.MOYASAR_API_BASE}/invoices`, {
      method: "POST",
      headers: { Authorization: `Basic ${authorization}`, "Content-Type": "application/json", Accept: "application/json" },
      body: JSON.stringify({
        amount: input.amountHalalas,
        currency: input.currency,
        description: input.description,
        metadata: { orderId: input.orderId }
      }),
      signal: AbortSignal.timeout(15_000)
    });
    const body = await response.json() as { id?: string; url?: string; message?: string };
    if (!response.ok || !body.id || !body.url) throw new Error(body.message ?? `Moyasar invoice creation failed (${response.status})`);
    return { providerReference: body.id, checkoutUrl: body.url };
  }
  handleWebhook(payload: unknown) { return parseWebhook(payload, "moyasar"); }
}

export const paymentProvider: PaymentProvider = env.PAYMENT_PROVIDER === "moyasar" ? new MoyasarProvider() : new MockProvider();
