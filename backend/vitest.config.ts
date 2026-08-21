import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    // Tests share a local SQLite database and must not run in parallel.
    fileParallelism: false,
  },
});
