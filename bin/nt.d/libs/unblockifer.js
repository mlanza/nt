// Helper function from the original code
function normalizeSeparator(lines) {
  return lines.filter(line => line.trim() !== '');
}

class Unblockifier {
  static convert(blocks, level = 0) {
    return this.recursiveConvert(blocks, level);
  }

  static recursiveConvert(blocks, level = 0) {
    const lines = [];
    const indent = '  '.repeat(level);
    const hanging = '  '.repeat(level + 1);

    blocks.forEach(function(block) {
      const {content, children} = block;
      if (content) {
        const [line, ...parts] = content.split("\n");
        if (line.includes("::")) {
          lines.push(`${indent}${line}`);
          for(const line of normalizeSeparator(parts)){
            lines.push(`${indent}${line}`);
          }
        } else {
          lines.push(`${indent}- ${line}`);
          for(const line of parts){
            if (!line.startsWith("collapsed:: ")) {
              lines.push(`${hanging}${line}`);
            }
          }
        }
      }

      if (children && children.length > 0) {
        lines.push(...Unblockifier.recursiveConvert(children, level + 1));
      }
    });

    return lines;
  }

  static reconst(blocks) {
    return this.recursiveConvert(blocks).join('\n');
  }
}

export default Unblockifier;