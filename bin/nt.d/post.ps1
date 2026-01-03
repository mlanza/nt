#!/usr/bin/env pwsh

# Post - Insert structured content into a Logseq page using insertBatchBlock
# Usage: nt p <source_page> | nt serial | nt post [--prepend] <target_page>

# Environment variables
$LOGSEQ_ENDPOINT = $env:LOGSEQ_ENDPOINT ?? ""
$LOGSEQ_TOKEN = $env:LOGSEQ_TOKEN ?? ""

# Check environment variables
if ([string]::IsNullOrEmpty($LOGSEQ_ENDPOINT) -or [string]::IsNullOrEmpty($LOGSEQ_TOKEN)) {
    Write-Error "Error: LOGSEQ_ENDPOINT and LOGSEQ_TOKEN environment variables must be set"
    exit 1
}

# Parse arguments
$PREPEND_MODE = $false
$PAGE_NAME = ""

if ($args.Count -eq 1) {
    $PAGE_NAME = $args[0]
} elseif ($args.Count -eq 2 -and $args[0] -eq "--prepend") {
    $PREPEND_MODE = $true
    $PAGE_NAME = $args[1]
} else {
    Write-Error "Usage: $($MyInvocation.MyCommand.Name) [--prepend] <page_name>"
    exit 1
}

# Read JSON payload from stdin
$PAYLOAD = [Console]::In.ReadToEnd()

# Validate payload is not empty
if ([string]::IsNullOrWhiteSpace($PAYLOAD)) {
    Write-Error "Error: No payload received from stdin"
    exit 1
}

Write-Host "Creating page '$PAGE_NAME' with structured content..." -ForegroundColor Yellow

# First, try to get the page to see if it exists
$PAGE_CHECK = curl -s -X POST "$LOGSEQ_ENDPOINT" `
    -H "Authorization: Bearer $LOGSEQ_TOKEN" `
    -H "Content-Type: application/json" `
    -d "{""method"":""logseq.Editor.getPage"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json

# Check if page exists and extract UUID
if ($PAGE_CHECK.uuid) {
    $PAGE_UUID = $PAGE_CHECK.uuid
    
    if ($PREPEND_MODE) {
        Write-Host "Page exists, prepending content..." -ForegroundColor Yellow
        
        # Get all page blocks to check for properties
        $PAGE_BLOCKS = curl -s -X POST "$LOGSEQ_ENDPOINT" `
            -H "Authorization: Bearer $LOGSEQ_TOKEN" `
            -H "Content-Type: application/json" `
            -d "{""method"":""logseq.Editor.getPageBlocksTree"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json
        
        # Find the last block with properties
        $LAST_PROPERTIES_BLOCK = $null
        if ($PAGE_BLOCKS) {
            foreach ($block in $PAGE_BLOCKS) {
                if ($block.properties -and $block.properties.PSObject.Properties.Count -gt 0) {
                    $LAST_PROPERTIES_BLOCK = $block
                }
            }
        }
        
        if ($LAST_PROPERTIES_BLOCK) {
            Write-Host "Found properties, inserting after them..." -ForegroundColor Yellow
            Write-Host "Properties content: $($LAST_PROPERTIES_BLOCK.content)" -ForegroundColor Cyan
            
            # Insert after the properties block using sibling:true
            $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
                -H "Authorization: Bearer $LOGSEQ_TOKEN" `
                -H "Content-Type: application/json" `
                -d "{
                    ""method"":""logseq.Editor.insertBatchBlock"",
                    ""args"":[
                        ""$($LAST_PROPERTIES_BLOCK.uuid)"",
                        $PAYLOAD,
                        {""sibling"":true}
                    ]
                }" | ConvertFrom-Json
        } else {
            Write-Host "No properties found, prepending to top..." -ForegroundColor Yellow
            
            # Prepend using page UUID with {sibling: false, before: true}
            $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
                -H "Authorization: Bearer $LOGSEQ_TOKEN" `
                -H "Content-Type: application/json" `
                -d "{
                    ""method"":""logseq.Editor.insertBatchBlock"",
                    ""args"":[
                        ""$PAGE_UUID"",
                        $PAYLOAD,
                        {""sibling"":false,""before"":true}
                    ]
                }" | ConvertFrom-Json
        }
    } else {
        Write-Host "Page exists, appending content..." -ForegroundColor Yellow
        $PAGE_BLOCKS = curl -s -X POST "$LOGSEQ_ENDPOINT" `
            -H "Authorization: Bearer $LOGSEQ_TOKEN" `
            -H "Content-Type: application/json" `
            -d "{""method"":""logseq.Editor.getPageBlocksTree"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json

        if ($PAGE_BLOCKS -is [array] -and $PAGE_BLOCKS.Count -gt 0) {
            $LAST_BLOCK_UUID = $PAGE_BLOCKS[-1].uuid
            Write-Host "Appending after block: $LAST_BLOCK_UUID" -ForegroundColor Yellow

            # Append after last block using sibling:true
            $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
                -H "Authorization: Bearer $LOGSEQ_TOKEN" `
                -H "Content-Type: application/json" `
                -d "{
                    ""method"":""logseq.Editor.insertBatchBlock"",
                    ""args"":[
                        ""$LAST_BLOCK_UUID"",
                        $PAYLOAD,
                        {""sibling"":true}
                    ]
                }" | ConvertFrom-Json
        } else {
            Write-Host "Page is empty, inserting at top..." -ForegroundColor Yellow
            $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
                -H "Authorization: Bearer $LOGSEQ_TOKEN" `
                -H "Content-Type: application/json" `
                -d "{
                    ""method"":""logseq.Editor.insertBatchBlock"",
                    ""args"":[
                        ""$PAGE_UUID"",
                        $PAYLOAD,
                        {""sibling"":false}
                    ]
                }" | ConvertFrom-Json
        }
    }
} else {
    Write-Host "Page doesn't exist, creating new page..." -ForegroundColor Yellow
    
    # Create the page first
    $CREATE_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
        -H "Authorization: Bearer $LOGSEQ_TOKEN" `
        -H "Content-Type: application/json" `
        -d "{""method"":""logseq.Editor.createPage"",""args"":[""$PAGE_NAME"",{}]}" | ConvertFrom-Json

    if ($CREATE_RESPONSE.uuid) {
        $PAGE_UUID = $CREATE_RESPONSE.uuid
        Write-Host "Created page with UUID: $PAGE_UUID" -ForegroundColor Green
        
        # Insert into new page using page UUID
        $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
            -H "Authorization: Bearer $LOGSEQ_TOKEN" `
            -H "Content-Type: application/json" `
            -d "{
                ""method"":""logseq.Editor.insertBatchBlock"",
                ""args"":[
                    ""$PAGE_UUID"",
                    $PAYLOAD,
                    {""sibling"":false}
                ]
            }" | ConvertFrom-Json
    } else {
        Write-Error "Error creating page. Response:"
        $CREATE_RESPONSE | ConvertTo-Json -Depth 10 | Write-Error
        exit 1
    }
}

# Check if insertion was successful
# Note: insertBatchBlock returns 'null' on success when creating new content
if ($null -eq $INSERT_RESPONSE) {
    $BLOCK_COUNT = ($PAYLOAD | ConvertFrom-Json).Count
    $ACTION = if ($PREPEND_MODE) { "Prepended" } else { "Appended" }
    Write-Host "✅ SUCCESS: $ACTION $BLOCK_COUNT blocks to page '$PAGE_NAME'" -ForegroundColor Green
} elseif ($INSERT_RESPONSE -is [array]) {
    $BLOCK_COUNT = $INSERT_RESPONSE.Count
    $ACTION = if ($PREPEND_MODE) { "Prepended" } else { "Added" }
    Write-Host "✅ SUCCESS: $ACTION $BLOCK_COUNT blocks to page '$PAGE_NAME'" -ForegroundColor Green
} else {
    Write-Error "Error creating page. Response:"
    $INSERT_RESPONSE | ConvertTo-Json -Depth 10 | Write-Error
    exit 1
}