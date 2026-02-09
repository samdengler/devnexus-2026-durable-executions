import { existsSync, appendFileSync } from "fs";
import { join } from "path";

// Check for a "FAIL" flag file to control demo failures
const FAIL_FLAG = join(process.cwd(), "FAIL_DEMO");
const REPLAY_LOG = join(process.cwd(), "replay-log.txt");

// This function will be called OUTSIDE ctx.run() to show replay behavior
export function logNonDurableStep(message: string) {
  const timestamp = new Date().toISOString();
  const logEntry = `[${timestamp}] ${message}\n`;

  // This will execute EVERY time, including on replay!
  console.log(`[NON-DURABLE] ${message} (${timestamp})`);
  appendFileSync(REPLAY_LOG, logEntry);
}

export function sendNotification(greetingId: string, name: string) {
  console.log(`Sending notification: ${greetingId} - ${name}`);

  // Deterministic failure for demo: check if FAIL_DEMO file exists
  if (existsSync(FAIL_FLAG)) {
    console.error(`[DEMO FAILURE] Notification service is down!`);
    throw new Error(`Notification service temporarily unavailable`);
  }

  console.log(`Notification sent successfully: ${greetingId} - ${name}`);
}

export function sendReminder(greetingId: string, name: string) {
  console.log(`Sending reminder: ${greetingId} - ${name}`);

  // This will succeed on replay after FAIL_DEMO is removed
  if (existsSync(FAIL_FLAG)) {
    console.error(`[DEMO FAILURE] Reminder service is down!`);
    throw new Error(`Reminder service temporarily unavailable`);
  }

  console.log(`Reminder sent successfully: ${greetingId} - ${name}`);
}
