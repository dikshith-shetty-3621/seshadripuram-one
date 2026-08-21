import { randomUUID } from 'node:crypto';
import { eq } from 'drizzle-orm';
import request from 'supertest';
import { afterEach, describe, expect, it } from 'vitest';
import { db } from '../src/db';
import { announcements, timetableEntries, users } from '../src/db/schema';
import { createApp } from '../src/index';
import { createAccessToken } from '../src/services/tokenService';

const app = createApp();
const userIds: string[] = [];
const announcementIds: string[] = [];
const timetableIds: string[] = [];

async function createUser(role: 'STUDENT' | 'TEACHER' | 'ADMIN'): Promise<string> {
  const id = randomUUID();
  userIds.push(id);
  await db.insert(users).values({ id, role, institutionId: `READ-${id}`, accountStatus: 'ACTIVE' });
  return id;
}

function token(userId: string, role: 'STUDENT' | 'TEACHER' | 'ADMIN'): string {
  return createAccessToken({ sub: userId, role, institutionId: `READ-${userId}` });
}

afterEach(async () => {
  for (const id of announcementIds.splice(0)) await db.delete(announcements).where(eq(announcements.id, id));
  for (const id of timetableIds.splice(0)) await db.delete(timetableEntries).where(eq(timetableEntries.id, id));
  for (const id of userIds.splice(0)) await db.delete(users).where(eq(users.id, id));
});

describe('academic read APIs', () => {
  it('returns published announcements for the authenticated role', async () => {
    const studentId = await createUser('STUDENT');
    const visibleId = randomUUID();
    const hiddenId = randomUUID();
    announcementIds.push(visibleId, hiddenId);
    await db.insert(announcements).values([
      { id: visibleId, title: 'Student notice', body: 'Visible to students', category: 'ACADEMIC', audienceRole: 'STUDENT', publishedAt: '2026-08-22T09:00:00.000Z', isPublished: true },
      { id: hiddenId, title: 'Teacher notice', body: 'Not visible to students', category: 'STAFF', audienceRole: 'TEACHER', publishedAt: '2026-08-22T10:00:00.000Z', isPublished: true },
    ]);

    const response = await request(app)
      .get('/api/academic/announcements')
      .set('Authorization', `Bearer ${token(studentId, 'STUDENT')}`)
      .expect(200);

    expect(response.body.announcements.map((item: { id: string }) => item.id)).toContain(visibleId);
    expect(response.body.announcements.map((item: { id: string }) => item.id)).not.toContain(hiddenId);
  });

  it('returns active timetable entries only to authenticated users', async () => {
    const teacherId = await createUser('TEACHER');
    const activeId = randomUUID();
    const inactiveId = randomUUID();
    timetableIds.push(activeId, inactiveId);
    await db.insert(timetableEntries).values([
      { id: activeId, dayOfWeek: 2, startTime: '09:00', endTime: '10:00', subject: 'Web Technology', teacherName: 'Dr. Rao', room: 'Room 204', sectionName: 'BCA 4A', isActive: true },
      { id: inactiveId, dayOfWeek: 2, startTime: '11:00', endTime: '12:00', subject: 'Archived Class', teacherName: 'Dr. Rao', room: 'Room 204', sectionName: 'BCA 4A', isActive: false },
    ]);

    const response = await request(app)
      .get('/api/academic/timetable')
      .set('Authorization', `Bearer ${token(teacherId, 'TEACHER')}`)
      .expect(200);

    expect(response.body.timetable.map((item: { id: string }) => item.id)).toContain(activeId);
    expect(response.body.timetable.map((item: { id: string }) => item.id)).not.toContain(inactiveId);
  });
});
