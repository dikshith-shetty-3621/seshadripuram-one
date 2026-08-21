CREATE TABLE `institutions` (
  `id` text PRIMARY KEY NOT NULL,
  `code` text NOT NULL,
  `name` text NOT NULL,
  `city` text,
  `is_active` integer DEFAULT true NOT NULL,
  `created_at` text DEFAULT CURRENT_TIMESTAMP,
  `updated_at` text DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE UNIQUE INDEX `institutions_code_unique` ON `institutions` (`code`);
--> statement-breakpoint
CREATE TABLE `departments` (
  `id` text PRIMARY KEY NOT NULL,
  `institution_id` text NOT NULL,
  `code` text NOT NULL,
  `name` text NOT NULL,
  `is_active` integer DEFAULT true NOT NULL,
  `created_at` text DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `departments_institution_code_unique` ON `departments` (`institution_id`, `code`);
--> statement-breakpoint
CREATE INDEX `departments_institution_idx` ON `departments` (`institution_id`);
--> statement-breakpoint
CREATE TABLE `programs` (
  `id` text PRIMARY KEY NOT NULL,
  `department_id` text NOT NULL,
  `code` text NOT NULL,
  `name` text NOT NULL,
  `level` text NOT NULL,
  `duration_semesters` integer NOT NULL,
  `is_active` integer DEFAULT true NOT NULL,
  `created_at` text DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `programs_department_code_unique` ON `programs` (`department_id`, `code`);
--> statement-breakpoint
CREATE INDEX `programs_department_idx` ON `programs` (`department_id`);
--> statement-breakpoint
CREATE TABLE `academic_years` (
  `id` text PRIMARY KEY NOT NULL,
  `institution_id` text NOT NULL,
  `label` text NOT NULL,
  `start_date` text NOT NULL,
  `end_date` text NOT NULL,
  `is_current` integer DEFAULT false NOT NULL,
  `created_at` text DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`institution_id`) REFERENCES `institutions`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `academic_years_institution_label_unique` ON `academic_years` (`institution_id`, `label`);
--> statement-breakpoint
CREATE INDEX `academic_years_institution_idx` ON `academic_years` (`institution_id`);
--> statement-breakpoint
CREATE TABLE `semesters` (
  `id` text PRIMARY KEY NOT NULL,
  `academic_year_id` text NOT NULL,
  `number` integer NOT NULL,
  `label` text NOT NULL,
  `is_current` integer DEFAULT false NOT NULL,
  FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `semesters_academic_year_number_unique` ON `semesters` (`academic_year_id`, `number`);
--> statement-breakpoint
CREATE INDEX `semesters_academic_year_idx` ON `semesters` (`academic_year_id`);
--> statement-breakpoint
CREATE TABLE `sections` (
  `id` text PRIMARY KEY NOT NULL,
  `program_id` text NOT NULL,
  `academic_year_id` text NOT NULL,
  `semester_id` text NOT NULL,
  `name` text NOT NULL,
  `capacity` integer,
  `is_active` integer DEFAULT true NOT NULL,
  FOREIGN KEY (`program_id`) REFERENCES `programs`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`semester_id`) REFERENCES `semesters`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `sections_program_year_semester_name_unique` ON `sections` (`program_id`, `academic_year_id`, `semester_id`, `name`);
--> statement-breakpoint
CREATE INDEX `sections_program_idx` ON `sections` (`program_id`);
--> statement-breakpoint
CREATE INDEX `sections_semester_idx` ON `sections` (`semester_id`);
--> statement-breakpoint
CREATE TABLE `subjects` (
  `id` text PRIMARY KEY NOT NULL,
  `department_id` text NOT NULL,
  `code` text NOT NULL,
  `name` text NOT NULL,
  `credits` integer,
  `is_active` integer DEFAULT true NOT NULL,
  FOREIGN KEY (`department_id`) REFERENCES `departments`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `subjects_department_code_unique` ON `subjects` (`department_id`, `code`);
--> statement-breakpoint
CREATE INDEX `subjects_department_idx` ON `subjects` (`department_id`);
--> statement-breakpoint
CREATE TABLE `subject_offerings` (
  `id` text PRIMARY KEY NOT NULL,
  `subject_id` text NOT NULL,
  `section_id` text NOT NULL,
  `semester_id` text NOT NULL,
  `is_active` integer DEFAULT true NOT NULL,
  FOREIGN KEY (`subject_id`) REFERENCES `subjects`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`section_id`) REFERENCES `sections`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`semester_id`) REFERENCES `semesters`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `subject_offerings_subject_section_semester_unique` ON `subject_offerings` (`subject_id`, `section_id`, `semester_id`);
--> statement-breakpoint
CREATE INDEX `subject_offerings_section_idx` ON `subject_offerings` (`section_id`);
--> statement-breakpoint
CREATE INDEX `subject_offerings_semester_idx` ON `subject_offerings` (`semester_id`);
--> statement-breakpoint
CREATE TABLE `enrollments` (
  `id` text PRIMARY KEY NOT NULL,
  `student_id` text NOT NULL,
  `section_id` text NOT NULL,
  `academic_year_id` text NOT NULL,
  `semester_id` text NOT NULL,
  `status` text DEFAULT 'ACTIVE' NOT NULL,
  `enrolled_at` text DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`student_id`) REFERENCES `students`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`section_id`) REFERENCES `sections`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`academic_year_id`) REFERENCES `academic_years`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`semester_id`) REFERENCES `semesters`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `enrollments_student_section_semester_unique` ON `enrollments` (`student_id`, `section_id`, `semester_id`);
--> statement-breakpoint
CREATE INDEX `enrollments_student_idx` ON `enrollments` (`student_id`);
--> statement-breakpoint
CREATE INDEX `enrollments_section_idx` ON `enrollments` (`section_id`);
--> statement-breakpoint
CREATE TABLE `teaching_assignments` (
  `id` text PRIMARY KEY NOT NULL,
  `teacher_id` text NOT NULL,
  `subject_offering_id` text NOT NULL,
  `assignment_role` text DEFAULT 'PRIMARY' NOT NULL,
  `is_active` integer DEFAULT true NOT NULL,
  `assigned_at` text DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`teacher_id`) REFERENCES `teachers`(`id`) ON UPDATE no action ON DELETE no action,
  FOREIGN KEY (`subject_offering_id`) REFERENCES `subject_offerings`(`id`) ON UPDATE no action ON DELETE no action
);
--> statement-breakpoint
CREATE UNIQUE INDEX `teaching_assignments_teacher_offering_unique` ON `teaching_assignments` (`teacher_id`, `subject_offering_id`);
--> statement-breakpoint
CREATE INDEX `teaching_assignments_teacher_idx` ON `teaching_assignments` (`teacher_id`);
--> statement-breakpoint
CREATE INDEX `teaching_assignments_offering_idx` ON `teaching_assignments` (`subject_offering_id`);
