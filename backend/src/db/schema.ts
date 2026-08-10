import { index, integer, sqliteTable, text, uniqueIndex } from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";

export const users = sqliteTable("users", {
  id: text("id").primaryKey(),
  role: text("role").notNull(), // 'STUDENT' | 'TEACHER' | 'ADMIN'
  passwordHash: text("password_hash"),
  accountStatus: text("account_status").notNull().default("PRE_PROVISIONED"),
  institutionId: text("institution_id"),
  contactEmail: text("contact_email"),
  isActive: integer("is_active", { mode: "boolean" }).notNull().default(true),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
  updatedAt: text("updated_at").default(sql`CURRENT_TIMESTAMP`),
}, (table) => [uniqueIndex("users_institution_id_unique").on(table.institutionId)]);

export const students = sqliteTable("students", {
  id: text("id").primaryKey(),
  userId: text("user_id").references(() => users.id).unique(),
  studentId: text("student_id").notNull().unique(),
  fullName: text("full_name").notNull(),
  contactEmail: text("contact_email").notNull(),
  isActive: integer("is_active", { mode: "boolean" }).notNull().default(true),
});

export const teachers = sqliteTable("teachers", {
  id: text("id").primaryKey(),
  userId: text("user_id").references(() => users.id).unique(),
  employeeId: text("employee_id").notNull().unique(),
  fullName: text("full_name").notNull(),
  contactEmail: text("contact_email").notNull(),
  isActive: integer("is_active", { mode: "boolean" }).notNull().default(true),
});

export const auditLogs = sqliteTable("audit_logs", {
  id: text("id").primaryKey(),
  action: text("action").notNull(),
  details: text("details"),
  timestamp: text("timestamp").default(sql`CURRENT_TIMESTAMP`),
});

export const otpSessions = sqliteTable("otp_sessions", {
  institutionId: text("institution_id").primaryKey(),
  otpHash: text("otp_hash").notNull(),
  expiresAt: integer("expires_at").notNull(),
  attempts: integer("attempts").notNull().default(0),
});

export const activationGrants = sqliteTable("activation_grants", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull().references(() => users.id),
  tokenHash: text("token_hash").notNull().unique(),
  expiresAt: integer("expires_at").notNull(),
  usedAt: integer("used_at"),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
}, (table) => [index("activation_grants_user_id_idx").on(table.userId)]);

export const authSessions = sqliteTable("auth_sessions", {
  id: text("id").primaryKey(),
  userId: text("user_id").notNull().references(() => users.id),
  refreshTokenHash: text("refresh_token_hash").notNull().unique(),
  expiresAt: integer("expires_at").notNull(),
  revokedAt: integer("revoked_at"),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
}, (table) => [index("auth_sessions_user_id_idx").on(table.userId)]);
