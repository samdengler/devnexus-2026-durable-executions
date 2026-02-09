import * as restate from "@restatedev/restate-sdk";
import { sendNotification, sendReminder, logNonDurableStep } from "./utils";

import { z } from "zod";

const Greeting = z.object({
  name: z.string(),
});

const GreetingResponse = z.object({
  result: z.string(),
});

const greeter = restate.service({
  name: "Greeter",
  handlers: {
    greet: restate.createServiceHandler(
      { input: restate.serde.schema(Greeting), output: restate.serde.schema(GreetingResponse) },
      async (ctx: restate.Context, { name }) => {
        // NOT DURABLE: This runs every time, including on replay!
        logNonDurableStep(`Handler started for ${name}`);

        // DURABLE: This is journaled and deterministic - same UUID on replay
        const greetingId = ctx.rand.uuidv4();
        console.log(`Generated UUID: ${greetingId} (deterministic via journal)`);

        // NOT DURABLE: This runs again on replay (but check the timestamp!)
        logNonDurableStep(`About to send notification for ${greetingId}`);

        // DURABLE: This side effect only executes once, result is journaled
        await ctx.run("Notification", () => sendNotification(greetingId, name));

        await ctx.sleep({ seconds: 1 });

        // DURABLE: This side effect only executes once, result is journaled
        await ctx.run("Reminder", () => sendReminder(greetingId, name));

        // NOT DURABLE: This runs again on replay
        logNonDurableStep(`Handler completed for ${name}`);

        // Respond to caller
        return { result: `You said hi to ${name}!` };
      },
    ),
  },
});

restate.serve({
  services: [greeter],
  port: 9080,
});
