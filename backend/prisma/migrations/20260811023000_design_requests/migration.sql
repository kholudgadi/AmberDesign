CREATE TABLE "DesignRequest" (
  "id" UUID NOT NULL,
  "customerId" UUID NOT NULL,
  "assignedDesignerId" UUID,
  "category" TEXT NOT NULL,
  "title" TEXT NOT NULL,
  "specifications" JSONB NOT NULL,
  "details" TEXT,
  "referenceUrls" TEXT[] DEFAULT ARRAY[]::TEXT[],
  "status" TEXT NOT NULL DEFAULT 'submitted',
  "serviceFeeHalalas" INTEGER NOT NULL DEFAULT 0,
  "platformFeeHalalas" INTEGER NOT NULL DEFAULT 0,
  "quotedHalalas" INTEGER,
  "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  "updatedAt" TIMESTAMP(3) NOT NULL,
  CONSTRAINT "DesignRequest_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "DesignRequest_customerId_createdAt_idx" ON "DesignRequest"("customerId", "createdAt");
CREATE INDEX "DesignRequest_assignedDesignerId_status_createdAt_idx" ON "DesignRequest"("assignedDesignerId", "status", "createdAt");
ALTER TABLE "DesignRequest" ADD CONSTRAINT "DesignRequest_customerId_fkey" FOREIGN KEY ("customerId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "DesignRequest" ADD CONSTRAINT "DesignRequest_assignedDesignerId_fkey" FOREIGN KEY ("assignedDesignerId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;
