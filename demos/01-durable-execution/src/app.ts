import * as restate from "@restatedev/restate-sdk";
import { sendNotification, sendReminder, log } from "./utils";

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
        log(`Handler started for ${name}`);

        const greetingId = ctx.rand.uuidv4();

        await ctx.run("Notification", () => {
          log(`Sending notification for ${greetingId}`);
          sendNotification({ idempotencyKey: greetingId, name });
        });

        await ctx.run("Reminder", () => {
          log(`Sending reminder for ${greetingId}`);
          sendReminder({ idempotencyKey: greetingId, name });
        });

        return { result: `You said hi to ${name}!` };
      },
    ),
  },
});

restate.serve({
  services: [greeter],
  port: 9080,
});
