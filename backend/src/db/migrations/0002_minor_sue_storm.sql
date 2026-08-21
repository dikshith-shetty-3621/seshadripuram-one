CREATE TABLE `import_jobs` (
	`id` text PRIMARY KEY NOT NULL,
	`actor_user_id` text NOT NULL,
	`entity` text NOT NULL,
	`status` text DEFAULT 'PREVIEWED' NOT NULL,
	`total_rows` integer NOT NULL,
	`valid_rows` integer NOT NULL,
	`invalid_rows` integer NOT NULL,
	`errors_json` text NOT NULL,
	`created_at` text DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (`actor_user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `import_jobs_actor_idx` ON `import_jobs` (`actor_user_id`);--> statement-breakpoint
CREATE INDEX `import_jobs_created_idx` ON `import_jobs` (`created_at`);