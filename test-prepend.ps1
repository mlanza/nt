#!/usr/bin/env pwsh

# Exploratory script to test prepend functionality using insertBatchBlock
# Based on findings from block-insertion.md - Strategy 2: True Prepend to Page Top

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

Write-Host "Testing prepend to page '$PAGE_NAME'..." -ForegroundColor Yellow

# Step 1: Get the page UUID (not blocks)
Write-Host "Getting page UUID..." -ForegroundColor Yellow
$PAGE_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
    -H "Authorization: Bearer $LOGSEQ_TOKEN" `
    -H "Content-Type: application/json" `
    -d "{""method"":""logseq.Editor.getPage"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json

if (-not $PAGE_RESPONSE.uuid) {
    Write-Error "Page '$PAGE_NAME' does not exist"
    exit 1
}

$PAGE_UUID = $PAGE_RESPONSE.uuid
Write-Host "Found page UUID: $PAGE_UUID" -ForegroundColor Green

# Step 2: Prepend using page UUID with {sibling: false, before: true}
Write-Host "Prepending content to top of page..." -ForegroundColor Yellow

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

# Check if insertion was successful
if ($null -eq $INSERT_RESPONSE) {
    $BLOCK_COUNT = ($PAYLOAD | ConvertFrom-Json).Count
    Write-Host "✅ SUCCESS: Prepended $BLOCK_COUNT blocks to page '$PAGE_NAME'" -ForegroundColor Green
} else {
    Write-Error "Error prepending content. Response:"
    $INSERT_RESPONSE | ConvertTo-Json -Depth 10 | Write-Error
    exit 1
}