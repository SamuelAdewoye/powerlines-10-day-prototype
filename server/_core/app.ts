import express, { type Express } from "express";
import { createExpressMiddleware } from "@trpc/server/adapters/express";
import { registerOAuthRoutes } from "./oauth.js";
import { registerStorageProxy } from "./storageProxy.js";
import { appRouter } from "../routers.js";
import { createContext } from "./context.js";
import { serveStatic } from "./vite.js";

/**
 * Creates the Express app without binding to a port.
 * Re-used by:
 *  - server/_core/index.ts (local dev / Manus / Docker) where we call listen()
 *  - api/index.ts (Vercel serverless) where Vercel invokes the handler per-request
 */
export async function createApp(): Promise<Express> {
  const app = express();

  // Body parsers – 50mb limit kept from original for uploads
  app.use(express.json({ limit: "50mb" }));
  app.use(express.urlencoded({ limit: "50mb", extended: true }));

  registerStorageProxy(app);
  registerOAuthRoutes(app);

  app.use(
    "/api/trpc",
    createExpressMiddleware({
      router: appRouter,
      createContext,
    })
  );

  // On Vercel, static files are served by the CDN from dist/public (outputDirectory).
  // Do NOT mount serveStatic there – it would try to resolve dist/public relative
  // to the serverless function's /var/task and return 500.
  const isVercel = process.env.VERCEL === "1";
  if (!isVercel && process.env.NODE_ENV !== "development") {
    serveStatic(app);
  }

  // Health check for Vercel / monitoring (no auth)
  app.get("/api/health", (_req: express.Request, res: express.Response) => {
    res.json({ ok: true, vercel: isVercel });
  });

  return app;
}
