CREATE TABLE IF NOT EXISTS users (
  id text PRIMARY KEY NOT NULL,
  role text NOT NULL,
  password_hash text,
  account_status text DEFAULT 'PRE_PROVISIONED' NOT NULL,
  created_at text DEFAULT CURRENT_TIMESTAMP,
  updated_at text DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS students (
  id text PRIMARY KEY NOT NULL,
  user_id text REFERENCES users(id),
  student_id text NOT NULL UNIQUE,
  full_name text NOT NULL,
  contact_email text NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS teachers (
  id text PRIMARY KEY NOT NULL,
  user_id text REFERENCES users(id),
  employee_id text NOT NULL UNIQUE,
  full_name text NOT NULL,
  contact_email text NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS audit_logs (
  id text PRIMARY KEY NOT NULL,
  action text NOT NULL,
  details text,
  timestamp text DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS otp_sessions (
  institution_id text PRIMARY KEY NOT NULL,
  otp_hash text NOT NULL,
  expires_at integer NOT NULL,
  attempts integer DEFAULT 0 NOT NULL
);
--> statement-breakpoint
ALTER TABLE users ADD COLUMN institution_id text;
--> statement-breakpoint
ALTER TABLE users ADD COLUMN contact_email text;
--> statement-breakpoint
ALTER TABLE users ADD COLUMN is_active integer DEFAULT 1 NOT NULL;
--> statement-breakpoint
ALTER TABLE students ADD COLUMN is_active integer DEFAULT 1 NOT NULL;
--> statement-breakpoint
ALTER TABLE teachers ADD COLUMN is_active integer DEFAULT 1 NOT NULL;
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS users_institution_id_unique ON users(institution_id);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS students_user_id_unique ON students(user_id);
--> statement-breakpoint
CREATE UNIQUE INDEX IF NOT EXISTS teachers_user_id_unique ON teachers(user_id);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS activation_grants (
  id text PRIMARY KEY NOT NULL,
  user_id text NOT NULL REFERENCES users(id),
  token_hash text NOT NULL UNIQUE,
  expires_at integer NOT NULL,
  used_at integer,
  created_at text DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS activation_grants_user_id_idx ON activation_grants(user_id);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS auth_sessions (
  id text PRIMARY KEY NOT NULL,
  user_id text NOT NULL REFERENCES users(id),
  refresh_token_hash text NOT NULL UNIQUE,
  expires_at integer NOT NULL,
  revoked_at integer,
  created_at text DEFAULT CURRENT_TIMESTAMP
);
--> statement-breakpoint
CREATE INDEX IF NOT EXISTS auth_sessions_user_id_idx ON auth_sessions(user_id);
