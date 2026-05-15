import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";
import * as c from "./libs/core.js";

export default function note(pi: ExtensionAPI) {
  // Helper to execute nt via pi.exec
  async function execNt(args: string[]): Promise<{ code: number; stdout: string; stderr: string }> {
    const result = await pi.exec("nt", args, { timeout: 10000 });
    return { code: result.code, stdout: result.stdout, stderr: result.stderr };
  }

  // Handle user input - expand wikilinks
  pi.on("input", async (event, ctx) => {
    const text = event.text;
    if (!text?.trim()) return { action: "continue" };
    if (event.source === "extension") return { action: "continue" };

    try {
      const { context, hasWikilinks } = await c.expand(text, execNt);
      if (!hasWikilinks) return { action: "continue" };
      if (context) {
        return { action: "transform", text: `${text}\n\n---\nContext from wikilinks:\n${context}` };
      }
      return { action: "continue" };
    } catch (error) {
      console.error(`[nt] Error: ${error}`);
      return { action: "continue" };
    }
  });
}
