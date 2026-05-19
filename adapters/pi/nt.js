import fs from 'fs';
import path from 'path';

/**
 * PI adapter for `nt prompt` with filesystem debugging.
 * Logs events and results to ./tmp/nt-debug.log
 */
const debugDir = path.join(process.cwd(), 'tmp');
fs.mkdirSync(debugDir, { recursive: true });

function logDebug(message) {
  const timestamp = new Date().toISOString();
  try {
    fs.appendFileSync(
      path.join(debugDir, 'nt-debug.log'),
      `${timestamp} ${message}\n`
    );
  } catch {
    // ignore write failures
  }
}

// Signal that this JS adapter has been loaded for debugging
logDebug(`[nt:adapter] module loaded; shell mode active; platform=${process.platform}, PATHEXT=${process.env.PATHEXT}`);

export default function note(pi) {
  pi.on('input', async (event) => {
    const text = event.text;
    logDebug(`[nt:adapter] event.source=${event.source}, text=${JSON.stringify(text)}`);
    logDebug(`[nt:adapter] env.platform=${process.platform}, PATHEXT=${process.env.PATHEXT}`);
    logDebug(`[nt:adapter] cwd=${process.cwd()}, PATH=${process.env.PATH}, LOGSEQ_REPO=${process.env.LOGSEQ_REPO}, LOGSEQ_ENDPOINT=${process.env.LOGSEQ_ENDPOINT}, LOGSEQ_TOKEN=${process.env.LOGSEQ_TOKEN}, NOTE_CONFIG=${process.env.NOTE_CONFIG}`);
    if (!text?.trim()) return { action: 'continue' };
    if (event.source === 'extension') return { action: 'continue' };

    try {
      const isWin = process.platform === 'win32';
      const cmd = isWin ? 'deno' : 'nt';
      const args = isWin
        ? ['run', '--allow-run', '--allow-read', '--allow-env', path.join(process.cwd(), 'bin', 'nt'), 'prompt', text]
        : ['prompt', text];
      logDebug(`[nt:adapter] executing ${cmd} ${JSON.stringify(args)}`);
      const result = await pi.exec(cmd, args, { timeout: 10000 });
      logDebug(
        `[nt:adapter] prompt command returned code=${result.code}, stdout=${JSON.stringify(result.stdout)}, stderr=${JSON.stringify(result.stderr)}`
      );
      if (result.code !== 0) {
        logDebug(`[nt:adapter] prompt failed: ${result.stderr}`);
        return { action: 'continue' };
      }
      logDebug(
        `[nt:adapter] transforming text to ${JSON.stringify(result.stdout || text)}`
      );
      return { action: 'transform', text: result.stdout || text };
    } catch (error) {
      logDebug(`[nt:adapter] prompt error: ${error}`);
      return { action: 'continue' };
    }
  });
}
