import { sqliteTable, text, integer } from "drizzle-orm/sqlite-core";
import { sql } from "drizzle-orm";

export const users = sqliteTable("users", {
  id: text("id").primaryKey(),
  role: text("role").notNull(), // 'STUDENT' | 'TEACHER' | 'ADMIN'
  passwordHash: text("password_hash"),
  accountStatus: text("account_status").notNull().default("PRE_PROVISIONED"),
  createdAt: text("created_at").default(sql`CURRENT_TIMESTAMP`),
  updatedAt: text("updated_at").default(sql`CURRENT_TIMESTAMP`),
});

export const students = sqliteTable("students", {
  id: text("id").primaryKey(),
  userId: text("user_id").references(() => users.id),
  studentId: text("student_id").notNull().unique(),
  fullName: text("full_name").notNull(),
  contactEmail: text("contact_email").notNull(),
});

export const teachers = sqliteTable("teachers", {
  id: text("id").primaryKey(),
  userId: text("user_id").references(() => users.id),
  employeeId: text("employee_id").notNull().unique(),
  fullName: text("full_name").notNull(),
  contactEmail: text("contact_email").notNull(),
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
