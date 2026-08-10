import { db } from "./index";
import { students, teachers } from "./schema";
import { v4 as uuidv4 } from "uuid";

async function seed() {
  console.log("Seeding database...");
  
  try {
    await db.insert(students).values({
      id: uuidv4(),
      studentId: "TEST-STUDENT-001",
      fullName: "Test Student",
      contactEmail: "student@example.com",
    });
    console.log("Inserted TEST-STUDENT-001");
  } catch (e) {
    console.log("TEST-STUDENT-001 might already exist");
  }

  try {
    await db.insert(teachers).values({
      id: uuidv4(),
      employeeId: "TEST-TEACHER-001",
      fullName: "Test Teacher",
      contactEmail: "teacher@example.com",
    });
    console.log("Inserted TEST-TEACHER-001");
  } catch (e) {
    console.log("TEST-TEACHER-001 might already exist");
  }

  console.log("Seeding complete!");
}

seed().catch(console.error).finally(() => process.exit(0));
