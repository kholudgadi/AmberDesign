import type { NextFunction, Request, Response } from "express";
import { ZodError, type ZodType } from "zod";

export class ApiError extends Error {
  constructor(public status: number, message: string, public code = "API_ERROR") {
    super(message);
  }
}

export const asyncHandler = (fn: (req: any, res: Response, next: NextFunction) => Promise<unknown>) =>
  (req: Request, res: Response, next: NextFunction) => Promise.resolve(fn(req, res, next)).catch(next);

export function parse<T>(schema: ZodType<T>, value: unknown): T {
  return schema.parse(value);
}

export function errorHandler(err: unknown, _req: Request, res: Response, _next: NextFunction) {
  if (err instanceof ZodError) {
    return res.status(422).json({ error: { code: "VALIDATION_ERROR", message: "Invalid request", details: err.flatten() } });
  }
  if (err instanceof ApiError) {
    return res.status(err.status).json({ error: { code: err.code, message: err.message } });
  }
  console.error(err);
  return res.status(500).json({ error: { code: "INTERNAL_ERROR", message: "Unexpected server error" } });
}

export function pageSize(raw: unknown, max = 50) {
  const size = Number(raw ?? 20);
  return Number.isInteger(size) && size > 0 ? Math.min(size, max) : 20;
}

export function pageCursor(raw: unknown) {
  if (raw === undefined || raw === null || raw === "") return undefined;
  if (typeof raw !== "string" || !/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.test(raw)) {
    throw new ApiError(422, "Invalid pagination cursor", "INVALID_CURSOR");
  }
  return raw;
}

export function paginated<T extends { id: string }>(rows: T[], limit: number) {
  const hasMore = rows.length > limit;
  const data = rows.slice(0, limit);
  return { data, meta: { count: data.length, hasMore, nextCursor: hasMore ? data.at(-1)?.id ?? null : null } };
}
