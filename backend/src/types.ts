import type { Request } from "express";

export const roles = ["customer", "designer", "vendor", "moderator", "admin"] as const;
export type Role = (typeof roles)[number];

export interface AuthUser {
  uid: string;
  email?: string;
  phone?: string;
  role: Role;
  disabled: boolean;
}

export interface AuthRequest extends Request {
  user?: AuthUser;
}

export const orderStatuses = [
  "pending_payment", "confirmed", "accepted", "in_progress", "ready",
  "shipped", "completed", "cancelled", "refunded"
] as const;
export type OrderStatus = (typeof orderStatuses)[number];
