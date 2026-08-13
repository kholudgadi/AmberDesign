import { describe, expect, it } from "vitest";
import { env } from "../config.js";
import { paymentProvider } from "./payments.js";

const event = (type: string, secret = env.PAYMENT_WEBHOOK_SECRET) => ({
  id: "event-1",
  type,
  secret_token: secret,
  data: { id: "payment-1", invoice_id: "invoice-1", amount: 12500, currency: "sar" }
});

describe("payment webhook parsing", () => {
  it("rejects an invalid webhook secret", () => {
    expect(() => paymentProvider.handleWebhook(event("payment_paid", "definitely-wrong"))).toThrow();
  });

  it.each(["payment_faild", "payment_failed"])("accepts Moyasar failed event spelling: %s", type => {
    expect(paymentProvider.handleWebhook(event(type))).toMatchObject({
      kind: "failed", providerReference: "invoice-1", amountHalalas: 12500, currency: "SAR"
    });
  });

  it("uses invoice_id to correlate a hosted invoice payment", () => {
    expect(paymentProvider.handleWebhook(event("payment_paid"))).toMatchObject({ kind: "paid", providerReference: "invoice-1" });
  });
});
