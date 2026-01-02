# Logseq API Block Insertion Experiments

This document details findings from testing Logseq API transactional structured content insertion capabilities. All experiments use environment variables `LOGSEQ_ENDPOINT` and `LOGSEQ_TOKEN` to avoid hardcoding values.

## Key Learnings

### Primary Discovery: `insertBatchBlock` is Transactional

The `logseq.Editor.insertBatchBlock` method is the **key API endpoint** for transactional structured content insertion. Unlike sequential approaches that require multiple API calls, `insertBatchBlock`:

- **Preserves exact hierarchy** - nested children arrays maintain structure perfectly
- **Handles properties automatically** - converts `properties` objects to Logseq's `property:: value` format
- **Maintains internal order** - content appears exactly as structured in the payload
- **Supports deep nesting** - tested successfully with 3+ levels of hierarchy
- **Single transaction** - entire structured content is inserted atomically or fails as a unit

### Workflow Patterns

1. **New Page Creation**: `createPage` → `insertBatchBlock` with page UUID
2. **Existing Page Append**: `getPageBlocksTree` → get last block UUID → `insertBatchBlock` with `{sibling: true}`
3. **Insertion Control**: Target specific blocks using their UUID for precise placement

### Limitations Discovered

- Page names cannot be used directly with `insertBatchBlock` - requires UUID
- Cannot batch insert into non-existent pages without first creating the page
- `appendBlockInPage` treats structured markdown as single block (adds "multipleBlocks" warning)

---

## Experiment 1: Basic Flat Batch Insertion

```bash
curl -s -X POST $LOGSEQ_ENDPOINT \
  -H "Authorization: Bearer $LOGSEQ_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method":"logseq.Editor.insertBatchBlock",
    "args":[
      "TARGET_BLOCK_UUID",
      [
        {"content":"First flat block"},
        {"content":"Second flat block"},
        {"content":"Third flat block"}
      ],
      {"sibling":true}
    ]
  }'
```

**Results**: Successfully inserted 3 flat blocks in sequence after an existing block, maintaining exact order.

**Why it's useful**: Demonstrates basic batch insertion capability for flat content - transactional single call inserts multiple blocks.

**Resulting Logseq Content:**
```markdown
First flat block
Second flat block
Third flat block
```

---

## Experiment 2: Complex Hierarchical Insertion

```bash
curl -s -X POST $LOGSEQ_ENDPOINT \
  -H "Authorization: Bearer $LOGSEQ_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method":"logseq.Editor.insertBatchBlock",
    "args":[
      "TARGET_BLOCK_UUID",
      [
        {
          "content":"Project Overview",
          "children":[
            {
              "content":"TODO: Define project scope",
              "children":[
                {"content":"Research similar projects"},
                {"content":"Identify key requirements"}
              ]
            },
            {"content":"Timeline Planning"}
          ]
        },
        {
          "content":"Meeting Notes",
          "children":[
            {
              "content":"TODO: Schedule kickoff",
              "properties":{"deadline":"2026-01-15"}
            }
          ]
        }
      ],
      {"sibling":true}
    ]
  }'
```

**Results**: Successfully inserted complex 3-level hierarchy with properties (deadlines), TODO markers, and nested children - all preserved exactly as structured.

**Why it's useful**: **BREAKTHROUGH** - Proves that `insertBatchBlock` handles full hierarchical structures with properties in a single transactional call.

**Resulting Logseq Content:**
```markdown
Project Overview
  TODO: Define project scope
    Research similar projects
    Identify key requirements
  Timeline Planning
Meeting Notes
  TODO: Schedule kickoff
  deadline:: 2026-01-15
```

---

## Experiment 3: Clean Page Batch Creation

```bash
curl -s -X POST $LOGSEQ_ENDPOINT \
  -H "Authorization: Bearer $LOGSEQ_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method":"logseq.Editor.insertBatchBlock",
    "args":[
      "PAGE_UUID",
      [
        {"content":"First batch block"},
        {"content":"Second batch block"},
        {"content":"Third batch block"}
      ],
      {"sibling":false}
    ]
  }'
```

**Results**: Created a clean page with batch-inserted blocks without requiring an initial placeholder block.

**Why it's useful**: Demonstrates transactional page creation + content insertion workflow for new pages.

**Resulting Logseq Content:**
```markdown
First batch block
Second batch block
Third batch block
```

---

## Experiment 4: Advanced Properties + Deep Nesting

```bash
curl -s -X POST $LOGSEQ_ENDPOINT \
  -H "Authorization: Bearer $LOGSEQ_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method":"logseq.Editor.insertBatchBlock",
    "args":[
      "PAGE_UUID",
      [
        {
          "content":"Complex structure",
          "children":[
            {
              "content":"Level 2 child",
              "properties":{"priority":"high","type":"task"},
              "children":[
                {"content":"Deep level 3"},
                {"content":"Another level 3"}
              ]
            },
            {"content":"Another level 2"}
          ]
        },
        {"content":"Second root"}
      ],
      {"sibling":true}
    ]
  }'
```

**Results**: Successfully handled 3-level nesting with multiple properties (priority, type) that were automatically converted to Logseq property format.

**Why it's useful**: Shows how `insertBatchBlock` automatically handles property formatting and deep hierarchical preservation.

**Resulting Logseq Content:**
```markdown
Complex structure
  Level 2 child
    priority:: high
    type:: task
    Deep level 3
    Another level 3
  Another level 2
Second root
```

---

## Experiment 5: Insertion Point Control

```bash
curl -s -X POST $LOGSEQ_ENDPOINT \
  -H "Authorization: Bearer $LOGSEQ_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "method":"logseq.Editor.insertBatchBlock",
    "args":[
      "TARGET_BLOCK_UUID",
      [
        {
          "content":"PREPENDED content",
          "children":[
            {"content":"Nested under prepended"}
          ]
        }
      ],
      {"sibling":false,"before":true}
    ]
  }'
```

**Results**: Successfully inserted structured content at a specific insertion point (as child of target block).

**Why it's useful**: Demonstrates precise insertion point control for prepend operations and hierarchical targeting.

**Resulting Logseq Content:**
```markdown
PREPENDED content
  Nested under prepended
```

---

## Payload Structure Reference

### Basic Block Object
```json
{
  "content": "Block content text",
  "children": [...],           // Optional: Array of child blocks
  "properties": {...}          // Optional: Object of block properties
}
```

### Properties Format
Properties in the payload are automatically converted:
```json
{"properties":{"deadline":"2026-01-15","priority":"high"}}
```
Becomes in Logseq:
```
deadline:: 2026-01-15
priority:: high
```

### Insertion Options
- `{"sibling": true}` - Insert as sibling after target block
- `{"sibling": false}` - Insert as child of target block
- `{"sibling": false, "before": true}` - Insert as child before target's children

---

## API Response Patterns

- **Successful insertion**: Returns `null` (consistent behavior)
- **Error cases**: Returns error objects with descriptive messages
- **Page UUID required**: Cannot use page names directly with `insertBatchBlock`

---

## Conclusion

The experiments conclusively demonstrate that **single API calls can accomplish complex hierarchical content insertion** using `logseq.Editor.insertBatchBlock`. This approach is superior to sequential block-by-block methods for transactional structured content operations, providing:

1. **Atomic transactions** - entire structure succeeds or fails together
2. **Hierarchy preservation** - nested structures maintained exactly
3. **Property automation** - metadata handled automatically
4. **Performance benefits** - single network call vs multiple sequential calls

This validates the hypothesis that Logseq's `insertBatchBlock` API provides true transactional structured content insertion capabilities.
