import { Router } from "express";
import { requireAuthentication, requireRole } from "../middleware/auth";

/**
 * Authorization boundary for future academic write APIs. Feature handlers are
 * intentionally deferred, but no unauthorised caller can reach them.
 */
export const academicRouter = Router();

academicRouter.post("/attendance", requireAuthentication, requireRole("TEACHER", "ADMIN"), (_req, res) => {
  res.status(501).json({ error: "Attendance entry is not implemented yet" });
});
