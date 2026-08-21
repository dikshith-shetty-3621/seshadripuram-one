import { randomUUID } from 'node:crypto';
import request from 'supertest';
import { eq } from 'drizzle-orm';
import { afterEach, describe, expect, it } from 'vitest';
import { db } from '../src/db';
import { importJobs, users } from '../src/db/schema';
import { createApp } from '../src/index';
import { createAccessToken } from '../src/services/tokenService';

const app = createApp();
const createdUserIds: string[] = [];

function createToken(userId: string, role: 'STUDENT' | 'ADMIN'): string {
  return createAccessToken({
    sub: userId,
    role,
    institutionId: `${role}-${userId}`,
  });
}

async function createUser(role: 'STUDENT' | 'ADMIN'): Promise<string> {
  const id = randomUUID();
  createdUserIds.push(id);
  await db.insert(users).values({
    id,
    role,
    institutionId: `${role}-${id}`,
    accountStatus: 'ACTIVE',
  });
  return id;
}

afterEach(async () => {
  for (const id of createdUserIds.splice(0)) {
    await db.delete(importJobs).where(eq(importJobs.actorUserId, id));
    await db.delete(users).where(eq(users.id, id));
  }
});

describe('admin import preview', () => {
  it('rejects non-admin users', async () => {
    const studentId = await createUser('STUDENT');
    await request(app)
      .post('/api/admin/imports/preview')
      .set('Authorization', `Bearer ${createToken(studentId, 'STUDENT')}`)
      .send({ entity: 'departments', rows: [{ code: 'CS', name: 'Computer Science' }] })
      .expect(403);
  });

  it('reports duplicate and missing fields without writing academic records', async () => {
    const adminId = await createUser('ADMIN');
    const response = await request(app)
      .post('/api/admin/imports/preview')
      .set('Authorization', `Bearer ${createToken(adminId, 'ADMIN')}`)
      .send({
        entity: 'departments',
        rows: [
          { code: 'CS', name: 'Computer Science' },
          { code: 'CS', name: 'Computer Science Duplicate' },
          { code: '', name: 'Missing code' },
        ],
      })
      .expect(201);

    expect(response.body.totalRows).toBe(3);
    expect(response.body.validRows).toBe(1);
    expect(response.body.invalidRows).toBe(2);
    expect(response.body.errors).toHaveLength(2);
    expect(response.body.message).toContain('No records were written');

    const stored = await db.select().from(importJobs).where(eq(importJobs.id, response.body.importJobId));
    expect(stored).toHaveLength(1);
  });
});
