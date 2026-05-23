import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as path from "path";
import { fileURLToPath } from "url";

const adapterDir = path.dirname(fileURLToPath(import.meta.url));
const ntScript = path.join(adapterDir, "..", "..", "bin", "nt");

export default function note(pi: ExtensionAPI) {
  pi.on("input", async (event) => {
    const text = event.text;
    if (!text?.trim()) return { action: "continue" };
    if (event.source === "extension") return { action: "continue" };

    try {
      // On Windows shebangs aren’t respected, so explicitly invoke the Deno script; elsewhere use the nt shim
      const isWin = process.platform === "win32";
      const cmd = isWin ? "deno" : "nt";
      const args = isWin
        ? [
            "run",
            "--allow-run",
            "--allow-read",
            "--allow-env",
            ntScript,
            "prompt",
            text,
          ]
        : ["prompt", text];
      const result = await pi.exec(cmd, args, { timeout: 10000 });
      if (result.code !== 0) {
        console.error(`[nt] prompt failed: ${result.stderr}`);
        return { action: "continue" };
      }
      return { action: "transform", text: result.stdout || text };
    } catch (error) {
      console.error(`[nt] prompt error: ${error}`);
      return { action: "continue" };
    }
  });
}
