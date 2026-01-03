#!/bin/bash

# demo-whole-page.sh
# Demonstrates single insertBatchBlock call for complete structured page

set -e

# Configuration
LOGSEQ_ENDPOINT="${LOGSEQ_ENDPOINT:-http://127.0.0.1:12315/api}"
LOGSEQ_TOKEN="${LOGSEQ_TOKEN}"

if [[ -z "$LOGSEQ_TOKEN" ]]; then
    echo "Error: LOGSEQ_TOKEN environment variable required"
    exit 1
fi

echo "=== Creating TestAtomic.md Page ==="

# Step 1: Create the page first
echo "Creating TestAtomic page..."
PAGE_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
    -H "Authorization: Bearer $LOGSEQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{
        "method":"logseq.Editor.createPage",
        "args":["TestAtomic", {"journal":false}]
    }')

PAGE_UUID=$(echo "$PAGE_RESPONSE" | jq -r '.uuid')
echo "Created page with UUID: $PAGE_UUID"

# Step 2: Create comprehensive structured payload
echo "Creating structured payload with all content types..."
echo "NOTE: In production, analyze existing page first to match patterns"

cat > /tmp/test_atomic_payload.json << 'EOF'
[
  {
    "content": "tags:: Programming, [[Test Framework]], [[Demo Page]]\\nicon:: 🧪\\nalias:: [[Atomic Demo]]\\ndescription:: Comprehensive demonstration page\\n",
    "properties": {
      "tags": ["Programming", "Test Framework", "Demo Page"],
      "icon": "🧪",
      "alias": ["Atomic Demo"],
      "description": "Comprehensive demonstration page"
    },
    "preBlock": true
  },
  {
    "content": "TODO Simple flat task with [[link]] to external resource",
    "marker": "TODO"
  },
  {
    "content": "DOING Currently active task",
    "marker": "DOING"
  },
  {
    "content": "DONE Completed task",
    "marker": "DONE"
  },
  {
    "content": "Complex nested task",
    "properties": {
      "priority": "high",
      "deadline": "2026-01-15"
    },
    "collapsed": true,
    "children": [
      {
        "content": "Nested level 2 task",
        "marker": "TODO",
        "children": [
          {
            "content": "Deep level 3 research",
            "properties": {
              "source": "documentation",
              "type": "research"
            }
          },
          {
            "content": "Implementation details",
            "children": [
              {
                "content": "Step 1: Setup environment"
              },
              {
                "content": "Step 2: Write code"
              },
              {
                "content": "Step 3: Test functionality"
              }
            ]
          }
        ]
      },
      {
        "content": "Another level 2 item with [[wikilink]] reference",
        "properties": {
          "status": "pending",
          "related": "[[Atomic]]"
        }
      }
    ]
  },
  {
    "content": "Task with multiple properties",
    "properties": {
      "tags": ["multi-prop", "example"],
      "priority": "medium",
      "type": "demonstration"
    },
    "children": [
      {
        "content": "Child with single property",
        "properties": {
          "category": "implementation"
        }
      },
      {
        "content": "Another child",
        "properties": {
          "difficulty": "easy"
        }
      }
    ]
  },
  {
    "content": "NOW Active focus item",
    "marker": "NOW",
    "properties": {
      "focus": "current sprint"
    }
  },
  {
    "content": "LATER Deferred task for next phase",
    "marker": "LATER",
    "properties": {
      "phase": "future",
      "timeline": "Q2 2026"
    }
  },
  {
    "content": "WAITING Blocked task",
    "marker": "WAITING",
    "properties": {
      "blocker": "dependency",
      "blocked_by": "[[External Library]]"
    }
  },
  {
    "content": "Mixed content block with regular text and [[inline]] links",
    "children": [
      {
        "content": "Regular child content"
      },
      {
        "content": "Child with [external URL](https://example.com) reference"
      },
      {
        "content": "Child with [[wikilink]] and more text"
      }
    ]
  },
  {
    "content": "Deeply nested structure demonstration",
    "children": [
      {
        "content": "Level 2 root",
        "children": [
          {
            "content": "Level 3 with properties",
            "properties": {
              "category": "deep",
              "importance": "low"
            },
            "children": [
              {
                "content": "Level 4 deepest item",
                "properties": {
                  "depth": "maximum",
                  "type": "test"
                }
              }
            ]
          },
          {
            "content": "Another level 3 item"
          }
        ]
      },
      {
        "content": "Second level 2 item"
      }
    ]
  },
  {
    "content": "Simple collapsed task",
    "collapsed": true,
    "properties": {
      "reason": "space saving",
      "detail": "not immediately relevant"
    }
  },
  {
    "content": "Final task with all possible elements",
    "properties": {
      "tags": ["final", "comprehensive", "demo"],
      "priority": "low",
      "deadline": "2026-02-01",
      "type": "milestone"
    },
    "children": [
      {
        "content": "Nested final child 1"
      },
      {
        "content": "Nested final child 2",
        "properties": {
          "status": "ready"
        }
      },
      {
        "content": "Nested final child 3 with [[FinalTarget]] link"
      }
    ]
  }
]
EOF

echo "Created payload with $(cat /tmp/test_atomic_payload.json | jq 'length') blocks"

# Step 3: Insert entire structured page in SINGLE API call
echo "Inserting entire page in single insertBatchBlock call..."

INSERT_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
    -H "Authorization: Bearer $LOGSEQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"method\":\"logseq.Editor.insertBatchBlock\",
        \"args\":[
            \"$PAGE_UUID\",
            $(cat /tmp/test_atomic_payload.json),
            {\"sibling\":false}
        ]
    }")

if [[ "$INSERT_RESPONSE" == "null" ]]; then
    echo "✅ SUCCESS: Inserted $(cat /tmp/test_atomic_payload.json | jq 'length') blocks in single API call!"
    echo ""
    echo "Page 'TestAtomic' created with comprehensive structured content:"
    echo "- Page properties (tags, icon, alias, description)"
    echo "- All task states (TODO, DOING, DONE, NOW, LATER, WAITING)"  
    echo "- Complex nesting (4+ levels deep)"
    echo "- Multiple properties (priority, deadline, tags, etc.)"
    echo "- Mixed content (regular text, URLs, wikilinks)"
    echo "- Collapsed states"
    echo "- Total: $(cat /tmp/test_atomic_payload.json | jq 'length') blocks inserted transactionally"
else
    echo "❌ ERROR: Failed to insert content"
    echo "Response: $INSERT_RESPONSE"
    exit 1
fi

echo ""
echo "=== Verification ==="
echo "You can now check the 'TestAtomic' page in Logseq to see:"
echo "- Complete page structure created in ONE transaction"
echo "- All hierarchy preserved exactly"
echo "- All properties formatted correctly"
echo "- No information loss from input → API"