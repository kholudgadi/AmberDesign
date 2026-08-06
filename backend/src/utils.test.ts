import { describe, expect, it } from "vitest";
import { z } from "zod";
import { pageSize, parse } from "./utils.js";

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
});
