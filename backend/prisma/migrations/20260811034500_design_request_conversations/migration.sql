ALTER TABLE "Conversation" ADD COLUMN "designRequestId" UUID;

ALTER TABLE "Conversation"
ADD CONSTRAINT "Conversation_designRequestId_fkey"
FOREIGN KEY ("designRequestId") REFERENCES "DesignRequest"("id")
ON DELETE SET NULL ON UPDATE CASCADE;

CREATE INDEX "Conversation_designRequestId_idx" ON "Conversation"("designRequestId");
