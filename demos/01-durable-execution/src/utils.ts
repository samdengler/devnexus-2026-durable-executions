import { existsSync, appendFileSync } from "fs";
import { join } from "path";

// Check for a "FAIL" flag file to control demo failures
const FAIL_FLAG = join(process.cwd(), "FAIL_DEMO");
const REPLAY_LOG = join(process.cwd(), "demo-log.txt");

let _invId = "";
export function setInvocationId(id: string) {
  _invId = id.startsWith("inv_") ? id.slice(0, 8) + ".." + id.slice(-4) : id.slice(0, 8);
}

// This function will be called OUTSIDE ctx.run() to show replay behavior
export function log(message: string) {
  const timestamp = new Date().toISOString();
  const prefix = _invId ? `[${_invId}]` : "";
  console.log(`${prefix}[LOG] ${message} (${timestamp})`);
  appendFileSync(REPLAY_LOG, `[${timestamp}]${prefix} ${message}\n`);
}

function sleepSync(ms: number) {
  Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);
}

// Poll loop: blocks while FAIL_DEMO exists, giving you time to kill the service
export function waitForFlag(label: string) {
  if (!existsSync(FAIL_FLAG)) return;
  console.log(`[DEMO] ${label} waiting... (kill this service now!)`);
  while (existsSync(FAIL_FLAG)) {
    sleepSync(1000);
    console.log(`[DEMO] ${label} still waiting...`);
  }
}

export function sendNotification({ idempotencyKey, name }: { idempotencyKey: string; name: string }) {
  console.log(`Sending notification: ${idempotencyKey} - ${name}`);
  console.log(`Notification sent successfully: ${idempotencyKey} - ${name}`);
}

export function sendReminder({ idempotencyKey, name }: { idempotencyKey: string; name: string }) {
  console.log(`Sending reminder: ${idempotencyKey} - ${name}`);
  console.log(`Reminder sent successfully: ${idempotencyKey} - ${name}`);
}
