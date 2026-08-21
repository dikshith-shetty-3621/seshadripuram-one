import { and, asc, desc, eq, isNull, or } from 'drizzle-orm';
import { Router } from 'express';
import { db } from '../db';
import { announcements, timetableEntries } from '../db/schema';
import { requireAuthentication, requireRole } from '../middleware/auth';

export const academicRouter = Router();

academicRouter.get('/announcements', requireAuthentication, async (req, res) => {
  const role = req.auth!.role;
  const rows = await db.select({
    id: announcements.id,
    title: announcements.title,
    body: announcements.body,
    category: announcements.category,
    publishedAt: announcements.publishedAt,
  }).from(announcements).where(and(
    eq(announcements.isPublished, true),
    or(isNull(announcements.audienceRole), eq(announcements.audienceRole, role), eq(announcements.audienceRole, 'ALL')),
  )).orderBy(desc(announcements.publishedAt)).limit(20);
  return res.json({ announcements: rows });
});

academicRouter.get('/timetable', requireAuthentication, async (_req, res) => {
  const rows = await db.select({
    id: timetableEntries.id,
    dayOfWeek: timetableEntries.dayOfWeek,
    startTime: timetableEntries.startTime,
    endTime: timetableEntries.endTime,
    subject: timetableEntries.subject,
    teacherName: timetableEntries.teacherName,
    room: timetableEntries.room,
    sectionName: timetableEntries.sectionName,
  }).from(timetableEntries).where(eq(timetableEntries.isActive, true)).orderBy(asc(timetableEntries.dayOfWeek), asc(timetableEntries.startTime)).limit(100);
  return res.json({ timetable: rows });
});

academicRouter.post('/attendance', requireAuthentication, requireRole('TEACHER', 'ADMIN'), (_req, res) => {
  res.status(501).json({ error: 'Attendance entry is not implemented yet' });
});
