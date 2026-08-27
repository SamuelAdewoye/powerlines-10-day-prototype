import type { Express } from "express";
import fs from "fs";
import path from "path";
import { ENV } from "./env.js";

export function registerStorageProxy(app: Express) {
  app.get("/manus-storage/*", async (req, res) => {
    const key = (req.params as Record<string, string>)[0];
    if (!key) {
      res.status(400).send("Missing storage key");
      return;
    }

    if (!ENV.forgeApiUrl || !ENV.forgeApiKey) {
      // Fallback: serve from bundled local public assets (for Vercel without Forge)
      const localCandidates = [
        path.resolve(process.cwd(), "client", "public", key),
        path.resolve(process.cwd(), "dist", "public", key),
        path.resolve(import.meta.dirname, "..", "..", "client", "public", key),
        path.resolve(import.meta.dirname, "public", key),
      ];
      for (const cand of localCandidates) {
        if (fs.existsSync(cand)) {
          res.sendFile(cand);
          return;
        }
      }
      res.status(404).send("Storage proxy not configured and local asset not found: " + key);
      return;
    }

    try {
      const forgeUrl = new URL(
        "v1/storage/presign/get",
        ENV.forgeApiUrl.replace(/\/+$/, "") + "/",
      );
      forgeUrl.searchParams.set("path", key);

      const forgeResp = await fetch(forgeUrl, {
        headers: { Authorization: `Bearer ${ENV.forgeApiKey}` },
      });

      if (!forgeResp.ok) {
        const body = await forgeResp.text().catch(() => "");
        console.error(`[StorageProxy] forge error: ${forgeResp.status} ${body}`);
        res.status(502).send("Storage backend error");
        return;
      }

      const { url } = (await forgeResp.json()) as { url: string };
      if (!url) {
        res.status(502).send("Empty signed URL from backend");
        return;
      }

      res.set("Cache-Control", "no-store");
      res.redirect(307, url);
    } catch (err) {
      console.error("[StorageProxy] failed:", err);
      res.status(502).send("Storage proxy error");
    }
  });
}
