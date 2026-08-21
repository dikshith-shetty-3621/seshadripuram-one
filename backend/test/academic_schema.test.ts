import { sql } from 'drizzle-orm';
import { describe, expect, it } from 'vitest';
import { db } from '../src/db';

describe('academic master-data migration', () => {
  it('creates the core academic tables', async () => {
    const rows = await db.all<{ name: string }>(sql`
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name NOT LIKE 'sqlite_%'
    `);

    const tables = new Set(rows.map((row) => row.name));
    for (const table of [
      'institutions',
      'departments',
      'programs',
      'academic_years',
      'semesters',
      'sections',
      'subjects',
      'subject_offerings',
      'enrollments',
      'teaching_assignments',
    ]) {
      expect(tables.has(table), `Expected table ${table} to exist`).toBe(true);
    }
  });
});
