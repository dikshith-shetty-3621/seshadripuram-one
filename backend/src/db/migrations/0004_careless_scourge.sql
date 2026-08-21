CREATE TABLE `announcements` (
	`id` text PRIMARY KEY NOT NULL,
	`title` text NOT NULL,
	`body` text NOT NULL,
	`category` text DEFAULT 'GENERAL' NOT NULL,
	`audience_role` text,
	`published_at` text NOT NULL,
	`is_published` integer DEFAULT false NOT NULL,
	`created_by_user_id` text,
	FOREIGN KEY (`created_by_user_id`) REFERENCES `users`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE INDEX `announcements_published_idx` ON `announcements` (`is_published`,`published_at`);--> statement-breakpoint
CREATE INDEX `announcements_audience_role_idx` ON `announcements` (`audience_role`);--> statement-breakpoint
CREATE TABLE `timetable_entries` (
	`id` text PRIMARY KEY NOT NULL,
	`day_of_week` integer NOT NULL,
	`start_time` text NOT NULL,
	`end_time` text NOT NULL,
	`subject` text NOT NULL,
	`teacher_name` text NOT NULL,
	`room` text NOT NULL,
	`section_name` text,
	`is_active` integer DEFAULT true NOT NULL
);
--> statement-breakpoint
CREATE INDEX `timetable_day_idx` ON `timetable_entries` (`day_of_week`,`start_time`);--> statement-breakpoint
CREATE INDEX `timetable_section_idx` ON `timetable_entries` (`section_name`);