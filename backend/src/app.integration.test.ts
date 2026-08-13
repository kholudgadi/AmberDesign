import { createServer, type Server } from "node:http";
import { afterAll, beforeAll, describe, expect, it, vi } from "vitest";

vi.mock("./database.js", () => ({
  prisma: {
    $queryRaw: vi.fn().mockResolvedValue([{ ok: 1 }])
  }
}));

vi.mock("./firebase.js", () => ({
  messaging: {},
  bucket: {},
  firebaseAuth: { verifyIdToken: vi.fn() }
}));

describe("HTTP application integration", () => {
  let server: Server | undefined;
  let baseUrl: string;

  beforeAll(async () => {
    const { app } = await import("./app.js");
    const testServer = createServer(app);
    server = testServer;
    await new Promise<void>(resolve => testServer.listen(0, "127.0.0.1", resolve));
    const address = testServer.address();
    if (!address || typeof address === "string") throw new Error("Test server did not bind");
    baseUrl = `http://127.0.0.1:${address.port}`;
  });

  afterAll(async () => {
    if (server) await new Promise<void>((resolve, reject) => server!.close(error => error ? reject(error) : resolve()));
  });

  it("serves health with security headers", async () => {
    const response = await fetch(`${baseUrl}/health`);
    expect(response.status).toBe(200);
    expect(response.headers.get("x-content-type-options")).toBe("nosniff");
    expect(await response.json()).toMatchObject({ status: "ok", database: "connected" });
  });

  it("rejects malformed registration before database access", async () => {
    const response = await fetch(`${baseUrl}/api/v1/auth/register`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ email: "invalid", password: "short" })
    });
    expect(response.status).toBe(422);
    expect(await response.json()).toMatchObject({ error: { code: "VALIDATION_ERROR" } });
  });

  it("returns a structured 404", async () => {
    const response = await fetch(`${baseUrl}/api/v1/does-not-exist`);
    expect(response.status).toBe(404);
    expect(await response.json()).toEqual({ error: { code: "NOT_FOUND", message: "Route not found" } });
  });
});
