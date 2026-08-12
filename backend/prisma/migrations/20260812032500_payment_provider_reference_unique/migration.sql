CREATE UNIQUE INDEX "Payment_provider_providerReference_key"
ON "Payment"("provider", "providerReference");
