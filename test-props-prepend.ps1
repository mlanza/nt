#!/usr/bin/env pwsh

# Properties-aware prepend script
# Finds properties blocks and inserts content after them (under properties, but above other content)

# Environment variables
$LOGSEQ_ENDPOINT = $env:LOGSEQ_ENDPOINT ?? ""
$LOGSEQ_TOKEN = $env:LOGSEQ_TOKEN ?? ""

# Check environment variables
if ([string]::IsNullOrEmpty($LOGSEQ_ENDPOINT) -or [string]::IsNullOrEmpty($LOGSEQ_TOKEN)) {
    Write-Error "Error: LOGSEQ_ENDPOINT and LOGSEQ_TOKEN environment variables must be set"
    exit 1
}

# Check arguments
if ($args.Count -ne 1) {
    Write-Error "Usage: $($MyInvocation.MyCommand.Name) <page_name>"
    exit 1
}

$PAGE_NAME = $args[0]

# Read JSON payload from stdin
$PAYLOAD = [Console]::In.ReadToEnd()

# Validate payload is not empty
if ([string]::IsNullOrWhiteSpace($PAYLOAD)) {
    Write-Error "Error: No payload received from stdin"
    exit 1
}

Write-Host "Testing properties-aware prepend to page '$PAGE_NAME'..." -ForegroundColor Yellow

# Step 1: Get all page blocks
Write-Host "Getting page blocks to find properties..." -ForegroundColor Yellow
$PAGE_BLOCKS = curl -s -X POST "$LOGSEQ_ENDPOINT" `
    -H "Authorization: Bearer $LOGSEQ_TOKEN" `
    -H "Content-Type: application/json" `
    -d "{""method"":""logseq.Editor.getPageBlocksTree"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json

if (-not $PAGE_BLOCKS -or $PAGE_BLOCKS.Count -eq 0) {
    Write-Host "Page is empty or doesn't exist" -ForegroundColor Yellow
    exit 0
}

# Step 2: Find the last block with properties
$LAST_PROPERTIES_BLOCK = $null
foreach ($block in $PAGE_BLOCKS) {
    if ($block.properties -and $block.properties.PSObject.Properties.Count -gt 0) {
        $LAST_PROPERTIES_BLOCK = $block
    }
}

if ($LAST_PROPERTIES_BLOCK) {
    Write-Host "Found properties block with UUID: $($LAST_PROPERTIES_BLOCK.uuid)" -ForegroundColor Green
    Write-Host "Properties content: $($LAST_PROPERTIES_BLOCK.content)" -ForegroundColor Cyan
    
    # Step 3: Insert after the properties block
    Write-Host "Inserting content after properties block..." -ForegroundColor Yellow
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
    
    if ($null -eq $INSERT_RESPONSE) {
        $BLOCK_COUNT = ($PAYLOAD | ConvertFrom-Json).Count
        Write-Host "✅ SUCCESS: Inserted $BLOCK_COUNT blocks after properties in page '$PAGE_NAME'" -ForegroundColor Green
    } else {
        Write-Error "Error inserting content. Response:"
        $INSERT_RESPONSE | ConvertTo-Json -Depth 10 | Write-Error
        exit 1
    }
} else {
    Write-Host "No properties found, falling back to page-top prepend..." -ForegroundColor Yellow
    # Fall back to regular prepend using page UUID
    $PAGE_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
        -H "Authorization: Bearer $LOGSEQ_TOKEN" `
        -H "Content-Type: application/json" `
        -d "{""method"":""logseq.Editor.getPage"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json
    
    if ($PAGE_RESPONSE.uuid) {
        $INSERT_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
            -H "Authorization: Bearer $LOGSEQ_TOKEN" `
            -H "Content-Type: application/json" `
            -d "{
                ""method"":""logseq.Editor.insertBatchBlock"",
                ""args"":[
                    ""$($PAGE_RESPONSE.uuid)"",
                    $PAYLOAD,
                    {""sibling"":false,""before"":true}
                ]
            }" | ConvertFrom-Json
        
        if ($null -eq $INSERT_RESPONSE) {
            $BLOCK_COUNT = ($PAYLOAD | ConvertFrom-Json).Count
            Write-Host "✅ SUCCESS: Prepended $BLOCK_COUNT blocks to page '$PAGE_NAME'" -ForegroundColor Green
        } else {
            Write-Error "Error prepending content. Response:"
            $INSERT_RESPONSE | ConvertTo-Json -Depth 10 | Write-Error
            exit 1
        }
    }
}