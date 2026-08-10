import { Router } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import { db } from "../db";
import { students, teachers, users, otpSessions, auditLogs } from "../db/schema";
import { eq } from "drizzle-orm";
import { v4 as uuidv4 } from "uuid";
import { ConsoleOtpService } from "../services/otpService";

export const authRouter = Router();
const otpService = new ConsoleOtpService();
const JWT_SECRET = process.env.JWT_SECRET || "supersecretdevelopmentkey";

authRouter.post("/activation/start", async (req, res) => {
  const { institutionId } = req.body;
  if (!institutionId) return res.status(400).json({ error: "Institution ID required" });

  try {
    let role = "";
    let destination = "";
    let accountStatus = "";

    const student = await db.select().from(students).where(eq(students.studentId, institutionId)).get();
    if (student) {
      role = "STUDENT";
      destination = student.contactEmail;
      if (student.userId) {
        const u = await db.select().from(users).where(eq(users.id, student.userId)).get();
        if (u) accountStatus = u.accountStatus;
      } else {
        accountStatus = "PRE_PROVISIONED";
      }
    } else {
      const teacher = await db.select().from(teachers).where(eq(teachers.employeeId, institutionId)).get();
      if (teacher) {
        role = "TEACHER";
        destination = teacher.contactEmail;
        if (teacher.userId) {
          const u = await db.select().from(users).where(eq(users.id, teacher.userId)).get();
          if (u) accountStatus = u.accountStatus;
        } else {
          accountStatus = "PRE_PROVISIONED";
        }
      }
    }

    if (!role) {
      return res.status(400).json({ error: "Unable to verify this account." });
    }

    if (accountStatus === "ACTIVE") {
      return res.status(400).json({ error: "Account already activated. Please log in." });
    }

    const otp = otpService.generateOtp();
    const otpHash = await bcrypt.hash(otp, 10);
    const expiresAt = Date.now() + 10 * 60 * 1000;

    await db.insert(otpSessions).values({
      institutionId,
      otpHash,
      expiresAt,
    }).onConflictDoUpdate({
      target: otpSessions.institutionId,
      set: { otpHash, expiresAt, attempts: 0 }
    });

    await otpService.sendOtp(destination, otp);
    await db.insert(auditLogs).values({ id: uuidv4(), action: "ACTIVATION_START", details: `Started for ${institutionId}` });

    return res.json({ message: "OTP sent to registered contact." });
  } catch (error) {
    console.error(error);
    return res.status(500).json({ error: "Internal server error" });
  }
});

authRouter.post("/activation/verify", async (req, res) => {
  const { institutionId, otp } = req.body;
  if (!institutionId || !otp) return res.status(400).json({ error: "Missing parameters" });

  const session = await db.select().from(otpSessions).where(eq(otpSessions.institutionId, institutionId)).get();
  
  if (!session) return res.status(400).json({ error: "Invalid or expired OTP session" });
  if (Date.now() > session.expiresAt) return res.status(400).json({ error: "OTP expired" });
  if (session.attempts >= 5) return res.status(400).json({ error: "Too many attempts" });

  const isValid = await bcrypt.compare(otp, session.otpHash);
  if (!isValid) {
    await db.update(otpSessions).set({ attempts: session.attempts + 1 }).where(eq(otpSessions.institutionId, institutionId));
    return res.status(400).json({ error: "Invalid OTP" });
  }

  await db.delete(otpSessions).where(eq(otpSessions.institutionId, institutionId));
  return res.json({ message: "OTP verified successfully. You may now set your password." });
});

authRouter.post("/activation/set-password", async (req, res) => {
  const { institutionId, password } = req.body;
  
  if (!password || password.length < 8) return res.status(400).json({ error: "Password must be at least 8 characters" });

  const passwordHash = await bcrypt.hash(password, 10);
  const userId = uuidv4();

  const student = await db.select().from(students).where(eq(students.studentId, institutionId)).get();
  if (student) {
    await db.insert(users).values({ id: userId, role: "STUDENT", passwordHash, accountStatus: "ACTIVE" });
    await db.update(students).set({ userId }).where(eq(students.studentId, institutionId));
  } else {
    const teacher = await db.select().from(teachers).where(eq(teachers.employeeId, institutionId)).get();
    if (teacher) {
      await db.insert(users).values({ id: userId, role: "TEACHER", passwordHash, accountStatus: "ACTIVE" });
      await db.update(teachers).set({ userId }).where(eq(teachers.employeeId, institutionId));
    }
  }

  await db.insert(auditLogs).values({ id: uuidv4(), action: "ACTIVATION_COMPLETE", details: `Account activated for ${institutionId}` });
  return res.json({ message: "Account activated successfully. Please log in." });
});

authRouter.post("/login", async (req, res) => {
  const { institutionId, password } = req.body;

  let userId = null;
  let role = "";
  
  const student = await db.select().from(students).where(eq(students.studentId, institutionId)).get();
  if (student && student.userId) {
    userId = student.userId;
    role = "STUDENT";
  } else {
    const teacher = await db.select().from(teachers).where(eq(teachers.employeeId, institutionId)).get();
    if (teacher && teacher.userId) {
      userId = teacher.userId;
      role = "TEACHER";
    }
  }

  if (!userId) return res.status(401).json({ error: "Invalid credentials" });

  const user = await db.select().from(users).where(eq(users.id, userId)).get();
  if (!user || user.accountStatus !== "ACTIVE") return res.status(401).json({ error: "Account inactive or disabled" });

  const isPasswordValid = await bcrypt.compare(password, user.passwordHash!);
  if (!isPasswordValid) return res.status(401).json({ error: "Invalid credentials" });

  const token = jwt.sign({ id: user.id, role: user.role, institutionId }, JWT_SECRET, { expiresIn: "7d" });
  await db.insert(auditLogs).values({ id: uuidv4(), action: "LOGIN_SUCCESS", details: `Login by ${institutionId}` });

  return res.json({ token, role: user.role });
});
