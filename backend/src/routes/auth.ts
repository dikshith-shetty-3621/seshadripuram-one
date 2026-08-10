import { randomUUID } from "node:crypto";
import bcrypt from "bcrypt";
import { Router } from "express";
import rateLimit from "express-rate-limit";
import { and, eq, gt, isNull } from "drizzle-orm";
import { db } from "../db";
import { activationGrants, auditLogs, authSessions, otpSessions, students, teachers, users } from "../db/schema";
import { requireAuthentication } from "../middleware/auth";
import { createOtpService } from "../services/otpService";
import { createAccessToken, createOpaqueToken, hashOpaqueToken, type AppRole } from "../services/tokenService";

export const authRouter = Router();
const otpService = createOtpService();
const otpExpiryMs = 10 * 60 * 1000;
const grantExpiryMs = 10 * 60 * 1000;
const refreshExpiryMs = 30 * 24 * 60 * 60 * 1000;

const activationLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 3,
  standardHeaders: true,
  legacyHeaders: false,
  // Test cases isolate persistence but intentionally do not share limiter state.
  skip: () => process.env.NODE_ENV === "test",
  message: { error: "Too many activation requests. Please try again later." },
});

interface Identity {
  userId: string;
  role: AppRole;
  institutionId: string;
  name: string;
  contactEmail: string | null;
  accountStatus: string;
  isActive: boolean;
}

function stringValue(body: unknown, key: string): string | null {
  if (!body || typeof body !== "object") return null;
  const value = (body as Record<string, unknown>)[key];
  return typeof value === "string" && value.trim() ? value.trim() : null;
}

function validRole(value: string): value is AppRole {
  return value === "STUDENT" || value === "TEACHER" || value === "ADMIN";
}

async function audit(action: string, details: string): Promise<void> {
  await db.insert(auditLogs).values({ id: randomUUID(), action, details });
}

async function resolveIdentity(institutionId: string): Promise<Identity | null> {
  const directUser = await db.select().from(users).where(eq(users.institutionId, institutionId)).get();
  if (directUser) {
    if (!validRole(directUser.role)) return null;
    return {
      userId: directUser.id,
      role: directUser.role,
      institutionId,
      name: institutionId,
      contactEmail: directUser.contactEmail,
      accountStatus: directUser.accountStatus,
      isActive: directUser.isActive,
    };
  }

  const student = await db.select().from(students).where(eq(students.studentId, institutionId)).get();
  if (student) return resolveProfileIdentity(student, "STUDENT", institutionId);

  const teacher = await db.select().from(teachers).where(eq(teachers.employeeId, institutionId)).get();
  if (teacher) return resolveProfileIdentity(teacher, "TEACHER", institutionId);

  return null;
}

async function resolveProfileIdentity(
  profile: { userId: string | null; fullName: string; contactEmail: string; isActive: boolean },
  role: Extract<AppRole, "STUDENT" | "TEACHER">,
  institutionId: string,
): Promise<Identity | null> {
  let user = profile.userId
    ? await db.select().from(users).where(eq(users.id, profile.userId)).get()
    : undefined;

  // Legacy authoritative profiles may not yet have an account row. Creating a
  // PRE_PROVISIONED account here is safe because the profile/role came from DB.
  if (!user) {
    const userId = randomUUID();
    await db.insert(users).values({
      id: userId,
      role,
      institutionId,
      contactEmail: profile.contactEmail,
      accountStatus: "PRE_PROVISIONED",
      isActive: profile.isActive,
    });
    if (role === "STUDENT") {
      await db.update(students).set({ userId }).where(eq(students.studentId, institutionId));
    } else {
      await db.update(teachers).set({ userId }).where(eq(teachers.employeeId, institutionId));
    }
    user = await db.select().from(users).where(eq(users.id, userId)).get();
  }
  if (!user) return null;
  return {
    userId: user.id,
    role,
    institutionId,
    name: profile.fullName,
    contactEmail: profile.contactEmail,
    accountStatus: user.accountStatus,
    isActive: profile.isActive && user.isActive,
  };
}

function publicUser(identity: Identity) {
  return { id: identity.userId, institutionId: identity.institutionId, name: identity.name, role: identity.role };
}

async function createSession(identity: Identity) {
  const refreshToken = createOpaqueToken();
  await db.insert(authSessions).values({
    id: randomUUID(),
    userId: identity.userId,
    refreshTokenHash: hashOpaqueToken(refreshToken),
    expiresAt: Date.now() + refreshExpiryMs,
  });
  return {
    accessToken: createAccessToken({ sub: identity.userId, role: identity.role, institutionId: identity.institutionId }),
    refreshToken,
    user: publicUser(identity),
  };
}

authRouter.post("/request-activation", activationLimiter, async (req, res) => {
  const institutionId = stringValue(req.body, "institutionId");
  if (!institutionId) return res.status(400).json({ error: "Institution ID is required" });

  try {
    const identity = await resolveIdentity(institutionId);
    if (!identity || !identity.isActive || !identity.contactEmail) {
      return res.status(404).json({ error: "No active account was found for this ID" });
    }
    if (identity.accountStatus === "ACTIVE") {
      return res.status(409).json({ error: "This account is already activated" });
    }

    const otp = otpService.generateOtp();
    await db.insert(otpSessions).values({
      institutionId,
      otpHash: await bcrypt.hash(otp, 12),
      expiresAt: Date.now() + otpExpiryMs,
    }).onConflictDoUpdate({
      target: otpSessions.institutionId,
      set: { otpHash: await bcrypt.hash(otp, 12), expiresAt: Date.now() + otpExpiryMs, attempts: 0 },
    });
    await otpService.sendOtp(identity.contactEmail, otp);
    await audit("ACTIVATION_REQUESTED", `Activation OTP requested for ${identity.userId}`);
    return res.status(202).json({ message: "An OTP was sent to the registered contact method" });
  } catch {
    return res.status(503).json({ error: "Activation is temporarily unavailable" });
  }
});

authRouter.post("/verify-otp", async (req, res) => {
  const institutionId = stringValue(req.body, "institutionId");
  const otp = stringValue(req.body, "otp");
  if (!institutionId || !otp || !/^\d{6}$/.test(otp)) return res.status(400).json({ error: "A valid institution ID and OTP are required" });

  const challenge = await db.select().from(otpSessions).where(eq(otpSessions.institutionId, institutionId)).get();
  if (!challenge || Date.now() > challenge.expiresAt) {
    if (challenge) await db.delete(otpSessions).where(eq(otpSessions.institutionId, institutionId));
    return res.status(400).json({ error: "OTP is invalid or expired" });
  }
  if (challenge.attempts >= 5) return res.status(429).json({ error: "Too many OTP attempts" });
  if (!(await bcrypt.compare(otp, challenge.otpHash))) {
    await db.update(otpSessions).set({ attempts: challenge.attempts + 1 }).where(eq(otpSessions.institutionId, institutionId));
    return res.status(400).json({ error: "OTP is invalid or expired" });
  }

  const identity = await resolveIdentity(institutionId);
  if (!identity || !identity.isActive || identity.accountStatus === "ACTIVE") {
    await db.delete(otpSessions).where(eq(otpSessions.institutionId, institutionId));
    return res.status(400).json({ error: "Account is not eligible for activation" });
  }
  const activationGrant = createOpaqueToken();
  await db.delete(otpSessions).where(eq(otpSessions.institutionId, institutionId));
  await db.insert(activationGrants).values({
    id: randomUUID(), userId: identity.userId, tokenHash: hashOpaqueToken(activationGrant), expiresAt: Date.now() + grantExpiryMs,
  });
  await audit("OTP_VERIFIED", `Activation OTP verified for ${identity.userId}`);
  return res.json({ activationGrant, expiresInSeconds: grantExpiryMs / 1000 });
});

authRouter.post("/set-password", async (req, res) => {
  const institutionId = stringValue(req.body, "institutionId");
  const activationGrant = stringValue(req.body, "activationGrant");
  const password = stringValue(req.body, "password");
  if (!institutionId || !activationGrant || !password || password.length < 12) {
    return res.status(400).json({ error: "Institution ID, activation grant, and a 12-character password are required" });
  }

  const identity = await resolveIdentity(institutionId);
  if (!identity || !identity.isActive) return res.status(404).json({ error: "No active account was found for this ID" });
  if (identity.accountStatus === "ACTIVE") return res.status(409).json({ error: "This account is already activated" });

  const grant = await db.select().from(activationGrants).where(and(
    eq(activationGrants.userId, identity.userId),
    eq(activationGrants.tokenHash, hashOpaqueToken(activationGrant)),
    isNull(activationGrants.usedAt),
    gt(activationGrants.expiresAt, Date.now()),
  )).get();
  if (!grant) return res.status(401).json({ error: "Activation verification is required" });

  await db.transaction(async (tx) => {
    await tx.update(users).set({ passwordHash: await bcrypt.hash(password, 12), accountStatus: "ACTIVE" }).where(eq(users.id, identity.userId));
    await tx.update(activationGrants).set({ usedAt: Date.now() }).where(eq(activationGrants.id, grant.id));
  });
  await audit("ACTIVATION_COMPLETED", `Account activated for ${identity.userId}`);
  return res.status(204).send();
});

authRouter.post("/login", async (req, res) => {
  const institutionId = stringValue(req.body, "institutionId");
  const password = stringValue(req.body, "password");
  if (!institutionId || !password) return res.status(400).json({ error: "Institution ID and password are required" });

  const identity = await resolveIdentity(institutionId);
  const user = identity ? await db.select().from(users).where(eq(users.id, identity.userId)).get() : undefined;
  if (!identity || !identity.isActive || identity.accountStatus !== "ACTIVE" || !user?.passwordHash) {
    return res.status(401).json({ error: "Invalid credentials" });
  }
  if (!(await bcrypt.compare(password, user.passwordHash))) return res.status(401).json({ error: "Invalid credentials" });

  const session = await createSession(identity);
  await audit("LOGIN_SUCCESS", `Login for ${identity.userId}`);
  return res.json(session);
});

authRouter.post("/refresh", async (req, res) => {
  const refreshToken = stringValue(req.body, "refreshToken");
  if (!refreshToken) return res.status(400).json({ error: "Refresh token is required" });
  const session = await db.select().from(authSessions).where(and(
    eq(authSessions.refreshTokenHash, hashOpaqueToken(refreshToken)), isNull(authSessions.revokedAt), gt(authSessions.expiresAt, Date.now()),
  )).get();
  if (!session) return res.status(401).json({ error: "Invalid or expired refresh token" });
  const user = await db.select().from(users).where(eq(users.id, session.userId)).get();
  if (!user?.institutionId || !validRole(user.role) || !user.isActive || user.accountStatus !== "ACTIVE") {
    return res.status(401).json({ error: "Session is no longer valid" });
  }
  const identity = await resolveIdentity(user.institutionId);
  if (!identity) return res.status(401).json({ error: "Session is no longer valid" });
  await db.update(authSessions).set({ revokedAt: Date.now() }).where(eq(authSessions.id, session.id));
  return res.json(await createSession(identity));
});

authRouter.post("/logout", async (req, res) => {
  const refreshToken = stringValue(req.body, "refreshToken");
  if (refreshToken) {
    await db.update(authSessions).set({ revokedAt: Date.now() }).where(eq(authSessions.refreshTokenHash, hashOpaqueToken(refreshToken)));
  }
  return res.status(204).send();
});

authRouter.get("/me", requireAuthentication, async (req, res) => {
  const user = await db.select().from(users).where(eq(users.id, req.auth!.sub)).get();
  if (!user?.institutionId || !user.isActive || user.accountStatus !== "ACTIVE" || !validRole(user.role)) {
    return res.status(401).json({ error: "Session is no longer valid" });
  }
  const identity = await resolveIdentity(user.institutionId);
  if (!identity) return res.status(401).json({ error: "Session is no longer valid" });
  return res.json({ user: publicUser(identity) });
});
