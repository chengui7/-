/**
 * Simple poster scaffold.
 * - Implement provider adapters using official SDKs and provide API keys in .env
 * - This file demonstrates how to schedule a post and call provider adapters.
 *
 * IMPORTANT: Follow each platform's developer rules and rate limits. Do NOT use to spam.
 */

require("dotenv").config();
const schedule = require("node-schedule");

const providers = [];

// Example adapter function stubs
async function postToTwitter(message) {
  // Placeholder: use twitter-api-v2 or official SDK here.
  // Example:
  // const client = new TwitterApi({
  //   appKey: process.env.TWITTER_API_KEY,
  //   appSecret: process.env.TWITTER_API_SECRET,
  //   accessToken: process.env.TWITTER_ACCESS_TOKEN,
  //   accessSecret: process.env.TWITTER_ACCESS_SECRET
  // });
  // await client.v2.tweet(message);
  console.log("[twitter] would post:", message);
}

async function postToInstagram(message) {
  // Placeholder: use Instagram Graph API (for business accounts) or Official SDK
  console.log("[instagram] would post:", message);
}

// Build provider list from env
if (process.env.TWITTER_API_KEY) providers.push(postToTwitter);
if (process.env.INSTAGRAM_API_TOKEN) providers.push(postToInstagram);

async function postToAllProviders(message) {
  for (const p of providers) {
    try {
      await p(message);
    } catch (err) {
      console.error("Provider failed:", err);
    }
  }
}

// Schedule posts based on CRON or run once for testing
const cron = process.env.POST_CRON_SCHEDULE || null;
const message = process.env.POST_MESSAGE || "DarkButterfly launch!";

if (cron) {
  console.log("Scheduling posts with cron:", cron);
  schedule.scheduleJob(cron, async () => {
    await postToAllProviders(message);
  });
} else {
  // Just run once
  postToAllProviders(message).then(() => console.log("One-off post done"));
}
