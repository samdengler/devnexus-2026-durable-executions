import { existsSync, appendFileSync } from "fs";
import { join } from "path";

// Check for a "FAIL" flag file to control demo failures
const FAIL_FLAG = join(process.cwd(), "FAIL_DEMO");
const REPLAY_LOG = join(process.cwd(), "replay-log.txt");

// This function will be called OUTSIDE ctx.run() to show replay behavior
export function log(message: string) {
  const timestamp = new Date().toISOString();
  console.log(`[LOG] ${message} (${timestamp})`);
  appendFileSync(REPLAY_LOG, `[${timestamp}] ${message}\n`);
}

export function sendNotification({ idempotencyKey, name }: { idempotencyKey: string; name: string }) {
  console.log(`Sending notification: ${idempotencyKey} - ${name}`);

  // Deterministic failure for demo: check if FAIL_DEMO file exists
  if (existsSync(FAIL_FLAG)) {
    console.error(`[DEMO FAILURE] Notification service is down!`);
    throw new Error(`Notification service temporarily unavailable`);
  }

  console.log(`Notification sent successfully: ${idempotencyKey} - ${name}`);
}

export function sendReminder({ idempotencyKey, name }: { idempotencyKey: string; name: string }) {
  console.log(`Sending reminder: ${idempotencyKey} - ${name}`);

  // This will succeed on replay after FAIL_DEMO is removed
  if (existsSync(FAIL_FLAG)) {
    console.error(`[DEMO FAILURE] Reminder service is down!`);
    throw new Error(`Reminder service temporarily unavailable`);
  }

  console.log(`Reminder sent successfully: ${idempotencyKey} - ${name}`);
}
