import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function note(pi: ExtensionAPI) {
  pi.on("input", async (event) => {
    const text = event.text;
    if (!text?.trim()) return { action: "continue" };
    if (event.source === "extension") return { action: "continue" };

    try {
      const result = await pi.exec("nt", ["prompt", text], { timeout: 10000 });
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
