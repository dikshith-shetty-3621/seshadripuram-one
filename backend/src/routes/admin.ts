import { Router } from 'express';
import { eq } from 'drizzle-orm';
import { db } from '../db';
import { importJobs } from '../db/schema';
import { requireAuthentication, requireRole } from '../middleware/auth';
import { validateImportPreview } from '../services/importValidation';
import { createOpaqueToken } from '../services/tokenService';

export const adminRouter = Router();

adminRouter.post('/imports/preview', requireAuthentication, requireRole('ADMIN'), async (req, res) => {
  const entity = typeof req.body?.entity === 'string' ? req.body.entity.trim() : '';
  const preview = validateImportPreview(entity, req.body?.rows);
  if ('error' in preview) return res.status(400).json(preview);

  const jobId = createOpaqueToken();
  await db.insert(importJobs).values({
    id: jobId,
    actorUserId: req.auth!.sub,
    entity: preview.entity,
    status: 'PREVIEWED',
    totalRows: preview.totalRows,
    validRows: preview.validRows,
    invalidRows: preview.invalidRows,
    errorsJson: JSON.stringify(preview.errors),
  });

  return res.status(201).json({
    importJobId: jobId,
    ...preview,
    message: preview.invalidRows === 0
      ? 'Preview is valid. No records were written.'
      : 'Preview contains errors. No records were written.',
  });
});

adminRouter.get('/imports/:id', requireAuthentication, requireRole('ADMIN'), async (req, res) => {
  const jobId = typeof req.params.id === 'string' ? req.params.id : null;
  if (!jobId) return res.status(400).json({ error: 'Import preview ID is required' });
  const job = await db.select().from(importJobs).where(eq(importJobs.id, jobId)).get();
  if (!job || job.actorUserId !== req.auth!.sub) return res.status(404).json({ error: 'Import preview not found' });

  return res.json({
    importJobId: job.id,
    entity: job.entity,
    status: job.status,
    totalRows: job.totalRows,
    validRows: job.validRows,
    invalidRows: job.invalidRows,
    errors: JSON.parse(job.errorsJson),
    createdAt: job.createdAt,
  });
});
