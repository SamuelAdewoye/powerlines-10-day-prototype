import { createApp } from "../server/_core/app.js";

// Vercel serverless handler – caches the Express app across invocations
let appPromise: Promise<any> | null = null;

function getApp() {
  if (!appPromise) {
    // Ensure Vercel flag is set so app skips serveStatic
    process.env.VERCEL = process.env.VERCEL || "1";
    appPromise = createApp();
  }
  return appPromise;
}

export default async function handler(req: any, res: any) {
  const app = await getApp();
  return app(req, res);
}
