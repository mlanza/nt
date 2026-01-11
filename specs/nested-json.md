# PRD: Blockifier ↔ nestedJsonToMarkdown Coupling Analysis

## Job description

I want to start by extracting Blockifer as a module to a libs folder in @bin/nt.d/ .  Create that as a module `blockifer.js` and put all the code from @bin/nt.d/note.js in that module.  Export it. Then import it into @bin/nt.d/note.js .  Take all the code from nestedJsonToMarkdown and put that into an unblockifer.js module in the same libs folder. Export it from that module, then import it into @bin/nt.d/note.js, same approach. Thus both the blockifer and unblockifier will live externally. 

I want to set you up for success.  

Before you start have a subagent run `nt p Atomic`, then run `nt p Atomic --less` and `nt p Atomic --only`.  Then, in your session do the refactoring.  

Then run `nt p Atomic | nt blocks | nt reconst` with each of the original runs.  

The `nt reconst` will be a reconsitute command which takes the output of blocks and compiles it back into markdown.  You are exposing this as a new command from within @bin/nt.d/note.js .  You are also using the Unblockifer as the basis of replcaing nestedJsonToMarkdown.  

The Unblockifer must be recursive in nature, doing all its recursion from within itself.  In this way, the refactoring of @bin/nt.d/note.js will be trivial. A drop in replacement, a one liner even.  In fact, expose the one liner as a static method on Unblockifer.  In the end, nestedJsonToMarkdown will be no more. The program will do all that it already does.  There will be a new `reconst` subcommand.  This is project work.

When you're done and you've done the lighter testing, using `head -n 10` on all the above to conserve context, you can ask the subagent on the same session left hanging around to run the tests again and confirm no differences with the unfettered context. And getting good results, return to me with a report of success.


## Overview
This document analyzes the tight coupling between the `Blockifier` class and `nestedJsonToMarkdown` function in `@bin/nt.d/note.js`, and the implications for replacing `nt struct` with `nt blocks`.

## Components Analysis

### Blockifier Class (lines 10222-13558)
**Purpose**: Parses markdown text into nested JSON block structure
**Input**: Raw markdown text
**Output**: Hierarchical JSON with specific schema:
```javascript
{
  content: string,
  properties?: object,
  preBlock?: boolean,  // Headers/properties blocks
  children?: array     // Nested blocks
}
```

**Key Characteristics**:
- Extracts properties into structured `properties` object
- Separates headers (`preBlock: true`) from content blocks
- Maintains hierarchical nesting via `children` arrays
- Handles bullet points, markers, and inline properties

### nestedJsonToMarkdown Function (lines 543-574)
**Purpose**: Converts Blockifier's JSON output back to markdown
**Input**: Blockifier JSON structure
**Output**: Formatted markdown text

**Key Characteristics**:
- **Tightly coupled** to Blockifier's exact JSON schema
- Expects `content` and `children` properties
- Hard-coded formatting logic for Blockifier's structure
- Specific indentation and bullet point rendering

## Coupling Evidence

### 1. Schema Dependency
```javascript
// nestedJsonToMarkdown expects exact Blockifier output
blocks.forEach(function(block) {
  const {content, children} = block;  // Expects these exact properties
```

### 2. Formatting Logic
```javascript
// Tailored for Blockifier's property handling
if (line.includes("::")) {
  lines.push(`${indent}${line}`);  // Properties inline
} else {
  lines.push(`${indent}- ${line}`); // Bullet points
}
```

### 3. Hierarchy Assumptions
```javascript
// Expects Blockifier's nested children structure
if (children && children.length > 0) {
  lines.push(...nestedJsonToMarkdown(children, level + 1));
}
```

## Integration Points

### Current Flow
1. `Blockifier.parse()` → JSON blocks
2. Filtering/manipulation of blocks
3. `nestedJsonToMarkdown()` → markdown output
4. Used by `nt page` command for filtered content rendering

### Usage Context
- **Primary**: `nt page` command with filtering (`--less`, `--only`)
- **Secondary**: Block manipulation workflows
- **Integration**: Called from `tskGetPage` when `format === "md"`

## Implications for struct → blocks Migration

### Current Challenge
- `document.ps1` uses `nt struct` (flat array with level properties)
- `nt blocks` uses Blockifier (hierarchical with different schema)
- `nestedJsonToMarkdown` only works with Blockifier output

### Potential Solutions
1. **Use nestedJsonToMarkdown directly**: Leverage existing coupling
2. **Write custom renderer**: Handle blocks JSON for document use case
3. **Modify nestedJsonToMarkdown**: Add document-specific rendering mode
4. **Create adapter**: Transform blocks JSON to struct-like format

### Technical Considerations
- **Schema Mismatch**: struct (flat + levels) vs blocks (hierarchical + children)
- **Property Handling**: struct (inline) vs blocks (structured properties object)
- **Content Formatting**: struct (preserves bullets) vs blocks (removes bullets)

## Recommendations

### Short-term
- Document this coupling for future reference
- Consider `nestedJsonToMarkdown` as purpose-built for block workflows
- Evaluate whether existing coupling can be leveraged for document rendering

### Long-term
- Assess if unified rendering approach is needed
- Consider whether document rendering should be separate concern
- Evaluate if Blockifier/blocks approach should replace struct entirely

## Technical Debt Notes
- `nestedJsonToMarkdown` is not a generic JSON-to-markdown converter
- High coupling makes independent evolution difficult
- Function serves specific use case (filtered page content rendering)
- No abstraction layer between parsing and rendering concerns

## File Locations
- **Blockifier**: `@bin/nt.d/note.js` lines 10222-13558
- **nestedJsonToMarkdown**: `@bin/nt.d/note.js` lines 543-574
- **Integration**: `tskGetPage` function calls `nestedJsonToMarkdown` for markdown output
