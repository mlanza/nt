#!/bin/bash

# Post - Insert structured content into a new Logseq page using insertBatchBlock
# Usage: nt p <source_page> | nt serial | nt post <target_page>

# Environment variables
LOGSEQ_ENDPOINT="${LOGSEQ_ENDPOINT:-}"
LOGSEQ_TOKEN="${LOGSEQ_TOKEN:-}"

# Check environment variables
if [[ -z "$LOGSEQ_ENDPOINT" || -z "$LOGSEQ_TOKEN" ]]; then
    echo "Error: LOGSEQ_ENDPOINT and LOGSEQ_TOKEN environment variables must be set" >&2
    exit 1
fi

# Check arguments
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <page_name>" >&2
    exit 1
fi

PAGE_NAME="$1"

# Read JSON payload from stdin
PAYLOAD=$(cat)

# Validate payload is not empty
if [[ -z "$PAYLOAD" ]]; then
    echo "Error: No payload received from stdin" >&2
    exit 1
fi

echo "Creating page '$PAGE_NAME' with structured content..." >&2

# First, try to get the page to see if it exists
PAGE_CHECK=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
    -H "Authorization: Bearer $LOGSEQ_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"method\":\"logseq.Editor.getPage\",\"args\":[\"$PAGE_NAME\"]}")

# Check if page exists and extract UUID
if echo "$PAGE_CHECK" | jq -e '.uuid' >/dev/null 2>&1; then
    PAGE_UUID=$(echo "$PAGE_CHECK" | jq '.uuid' -r)
    echo "Page exists, appending content..." >&2
else
    echo "Page doesn't exist, creating new page..." >&2
    # Create the page first
    CREATE_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
        -H "Authorization: Bearer $LOGSEQ_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"method\":\"logseq.Editor.createPage\",\"args\":[\"$PAGE_NAME\",{\"journal\":false}]}")

    if echo "$CREATE_RESPONSE" | jq -e '.uuid' >/dev/null 2>&1; then
        PAGE_UUID=$(echo "$CREATE_RESPONSE" | jq '.uuid' -r)
        echo "Created page with UUID: $PAGE_UUID" >&2
    else
        echo "Error creating page. Response:" >&2
        echo "$CREATE_RESPONSE" | jq . >&2
        exit 1
    fi
fi

# Remove debug output for cleaner usage

# For existing pages, get last block to append after it
if echo "$PAGE_CHECK" | jq -e '.uuid' >/dev/null 2>&1; then
    echo "Finding last block for append..." >&2
    PAGE_BLOCKS=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
        -H "Authorization: Bearer $LOGSEQ_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"method\":\"logseq.Editor.getPageBlocksTree\",\"args\":[\"$PAGE_NAME\"]}")

    if echo "$PAGE_BLOCKS" | jq -e '. | type == "array" and length > 0' >/dev/null 2>&1; then
        LAST_BLOCK_UUID=$(echo "$PAGE_BLOCKS" | jq '.[-1].uuid' -r)
        echo "Appending after block: $LAST_BLOCK_UUID" >&2

        # Append after last block using sibling:true
        INSERT_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
            -H "Authorization: Bearer $LOGSEQ_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"method\":\"logseq.Editor.insertBatchBlock\",
                \"args\":[
                    \"$LAST_BLOCK_UUID\",
                    $PAYLOAD,
                    {\"sibling\":true}
                ]
            }")
    else
        echo "Page is empty, inserting at top..." >&2
        INSERT_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
            -H "Authorization: Bearer $LOGSEQ_TOKEN" \
            -H "Content-Type: application/json" \
            -d "{
                \"method\":\"logseq.Editor.insertBatchBlock\",
                \"args\":[
                    \"$PAGE_UUID\",
                    $PAYLOAD,
                    {\"sibling\":false}
                ]
            }")
    fi
else
    # Insert into new page using page UUID
    INSERT_RESPONSE=$(curl -s -X POST "$LOGSEQ_ENDPOINT" \
        -H "Authorization: Bearer $LOGSEQ_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"method\":\"logseq.Editor.insertBatchBlock\",
            \"args\":[
                \"$PAGE_UUID\",
                $PAYLOAD,
                {\"sibling\":false}
            ]
        }")
fi



# Check if insertion was successful
# Note: insertBatchBlock returns 'null' on success when creating new content
if [[ "$INSERT_RESPONSE" == "null" ]]; then
    BLOCK_COUNT=$(echo "$PAYLOAD" | jq 'length')
    echo "✅ SUCCESS: Appended $BLOCK_COUNT blocks to page '$PAGE_NAME'"
elif echo "$INSERT_RESPONSE" | jq -e 'type == "array"' >/dev/null 2>&1; then
    BLOCK_COUNT=$(echo "$INSERT_RESPONSE" | jq 'length')
    echo "✅ SUCCESS: Added $BLOCK_COUNT blocks to page '$PAGE_NAME'"
else
    echo "Error creating page. Response:" >&2
    echo "$INSERT_RESPONSE" | jq . >&2
    exit 1
fi
