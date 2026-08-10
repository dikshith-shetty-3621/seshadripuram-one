import { db } from "./index";
import { students, teachers, users } from "./schema";
import { v4 as uuidv4 } from "uuid";

async function seed() {
  if (process.env.NODE_ENV === "production") {
    throw new Error("Development seed data must never run in production");
  }
  console.log("Seeding database...");
  
  try {
    const userId = uuidv4();
    await db.insert(users).values({ id: userId, institutionId: "TEST-STUDENT-001", role: "STUDENT", contactEmail: "student@example.com" });
    await db.insert(students).values({ id: uuidv4(), userId, studentId: "TEST-STUDENT-001", fullName: "Test Student", contactEmail: "student@example.com" });
    console.log("Inserted TEST-STUDENT-001");
  } catch (e) {
    console.log("TEST-STUDENT-001 might already exist");
  }

  try {
    const userId = uuidv4();
    await db.insert(users).values({ id: userId, institutionId: "TEST-TEACHER-001", role: "TEACHER", contactEmail: "teacher@example.com" });
    await db.insert(teachers).values({ id: uuidv4(), userId, employeeId: "TEST-TEACHER-001", fullName: "Test Teacher", contactEmail: "teacher@example.com" });
    console.log("Inserted TEST-TEACHER-001");
  } catch (e) {
    console.log("TEST-TEACHER-001 might already exist");
  }

  console.log("Seeding complete!");
}

seed().catch(console.error).finally(() => process.exit(0));
