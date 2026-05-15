/**
 * Extract wikilinks from text: [[wikilink]] patterns
 */
function extractWikilinks(text: string): string[] {
  const regex = /\[\[([^\]]+)\]\]/g;
  const links: string[] = [];
  let match;
  while ((match = regex.exec(text)) !== null) {
    links.push(match[1]);
  }
  return links;
}

/**
 * Process text through nt expansion
 * @param text - Input text containing wikilinks
 * @param execFn - Function to execute nt command (receives args array)
 * @returns Expanded context if wikilinks found
 */
export async function expand(
  text: string,
  execFn: (args: string[]) => Promise<{ code: number; stdout: string; stderr: string }>
): Promise<{ context: string; hasWikilinks: boolean }> {
  const links = extractWikilinks(text);

  if (links.length === 0) {
    return { context: "", hasWikilinks: false };
  }

  // Pass all links to nt about in a single call with --agent flag
  const result = await execFn(["about", ...links, "--agent"]);

  if (result.code !== 0 || !result.stdout.trim()) {
    // No successful expansion - return warning emoji for each link
    const warnings = links.map((l) => `⚠️ [[${l}]]`).join(", ");
    return { context: `[Wikilinks not found: ${warnings}]`, hasWikilinks: true };
  }

  return { context: result.stdout.trim(), hasWikilinks: true };
}
