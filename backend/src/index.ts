import cors from 'cors';
import express from 'express';
import rateLimit from 'express-rate-limit';
import { sql } from 'drizzle-orm';
import { randomUUID } from 'node:crypto';
import { config } from './config';
import { db } from './db';
import { academicRouter } from './routes/academic';
import { authRouter } from './routes/auth';

export function createApp() {
  const app = express();
  app.disable('x-powered-by');

  app.use((req, res, next) => {
    const requestId = req.header('x-request-id')?.trim() || randomUUID();
    res.setHeader('x-request-id', requestId);
    res.locals.requestId = requestId;
    next();
  });

  app.use(cors({
    origin(origin, callback) {
      // Native mobile clients commonly omit Origin. Browser clients must be allow-listed.
      if (!origin || config.corsOrigins.includes(origin)) return callback(null, true);
      return callback(new Error('Origin is not allowed'));
    },
  }));
  app.use(express.json({ limit: '32kb' }));

  app.use('/api/auth', rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
    standardHeaders: true,
    legacyHeaders: false,
    skip: () => process.env.NODE_ENV === 'test',
    message: { error: 'Too many requests. Please try again later.' },
  }), authRouter);
  app.use('/api/academic', academicRouter);

  app.get('/health', (_req, res) => res.json({ status: 'ok' }));
  app.get('/ready', async (_req, res) => {
    try {
      await db.run(sql`SELECT 1`);
      return res.json({ status: 'ready' });
    } catch {
      return res.status(503).json({ status: 'not_ready' });
    }
  });

  app.use((_req, res) => res.status(404).json({ error: 'Not found' }));
  app.use((error: unknown, _req: express.Request, res: express.Response, _next: express.NextFunction) => {
    const requestId = res.locals.requestId as string | undefined;
    console.error(JSON.stringify({
      event: 'unhandled_request_error',
      requestId,
      message: error instanceof Error ? error.message : 'Unknown error',
    }));
    res.status(500).json({ error: 'Internal server error', requestId });
  });
  return app;
}

if (require.main === module) {
  createApp().listen(config.port, () => console.info(`Server listening on port ${config.port}`));
}
