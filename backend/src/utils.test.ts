import { describe, expect, it } from "vitest";
import { z } from "zod";
import { pageCursor, pageSize, paginated, parse } from "./utils.js";

describe("request utilities", () => {
  it("caps page sizes", () => {
    expect(pageSize("999", 50)).toBe(50);
    expect(pageSize("bad", 50)).toBe(20);
    expect(pageSize("10", 50)).toBe(10);
  });

  it("validates request values", () => {
    expect(parse(z.object({ name: z.string().min(2) }), { name: "Amber" })).toEqual({ name: "Amber" });
    expect(() => parse(z.object({ name: z.string().min(2) }), { name: "A" })).toThrow();
  });

  it("validates cursors and returns stable pagination metadata", () => {
    const cursor = "550e8400-e29b-41d4-a716-446655440000";
    expect(pageCursor(cursor)).toBe(cursor);
    expect(() => pageCursor("not-a-cursor")).toThrow();
    expect(paginated([{ id: "1" }, { id: "2" }, { id: "3" }], 2)).toEqual({
      data: [{ id: "1" }, { id: "2" }],
      meta: { count: 2, hasMore: true, nextCursor: "2" }
    });
  });
});
