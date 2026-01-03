#!/usr/bin/env pwsh

# Purge - Remove all content blocks from a Logseq page while preserving properties
# Usage: nt purge [--debug] <page_name>

$LOGSEQ_ENDPOINT = $env:LOGSEQ_ENDPOINT ?? ""
$LOGSEQ_TOKEN = $env:LOGSEQ_TOKEN ?? ""

if ([string]::IsNullOrEmpty($LOGSEQ_ENDPOINT) -or [string]::IsNullOrEmpty($LOGSEQ_TOKEN)) {
    Write-Error "Error: LOGSEQ_ENDPOINT and LOGSEQ_TOKEN environment variables must be set"
    exit 1
}

$DEBUG_MODE = $false
$PAGE_NAME = ""

for ($i = 0; $i -lt $args.Count; $i++) {
    if ($args[$i] -eq "--debug") {
        $DEBUG_MODE = $true
    } else {
        $PAGE_NAME = $args[$i]
    }
}

if ([string]::IsNullOrEmpty($PAGE_NAME)) {
    Write-Error "Usage: nt purge [--debug] <page_name>"
    exit 1
}

if ($DEBUG_MODE) { Write-Host "Purging content from page '$PAGE_NAME'..." -ForegroundColor Yellow }

# Check if page exists
$PAGE_CHECK = curl -s -X POST "$LOGSEQ_ENDPOINT" `
    -H "Authorization: Bearer $LOGSEQ_TOKEN" `
    -H "Content-Type: application/json" `
    -d "{""method"":""logseq.Editor.getPage"",""args"":[""$PAGE_NAME""]}" | ConvertFrom-Json

if (-not $PAGE_CHECK.uuid) {
    Write-Error "Error: Page '$PAGE_NAME' does not exist"
    exit 1
}

$PAGE_UUID = $PAGE_CHECK.uuid
if ($DEBUG_MODE) { Write-Host "Page exists with UUID: $PAGE_UUID" -ForegroundColor Green }

# Get all page blocks using nt command (simpler)
$PAGE_BLOCKS_JSON = ./bin/nt p $PAGE_NAME --json
$PAGE_BLOCKS = $PAGE_BLOCKS_JSON | ConvertFrom-Json

if (-not $PAGE_BLOCKS -or $PAGE_BLOCKS.Count -eq 0) {
    Write-Host "✅ Page '$PAGE_NAME' is already empty" -ForegroundColor Green
    exit 0
}

# Find blocks to delete (those without meaningful properties)
$BLOCKS_TO_DELETE = @()
$PROPERTIES_BLOCKS_FOUND = @()

foreach ($block in $PAGE_BLOCKS) {
    $hasRealProperties = $false
    if ($block.properties -and $block.properties -is [PSCustomObject] -and $block.properties.PSObject.Properties.Count -gt 0) {
        if ($block.content -ne "" -or $block.content -ne $null) {
            $hasRealProperties = $true
        }
    }
    
    if ($hasRealProperties) {
        $PROPERTIES_BLOCKS_FOUND += $block
        if ($DEBUG_MODE) { Write-Host "Found properties block, keeping: $($block.uuid)" -ForegroundColor Cyan }
    } else {
        $BLOCKS_TO_DELETE += $block
        if ($DEBUG_MODE) { Write-Host "Marked for deletion: $($block.uuid) - content: '$($block.content)'" -ForegroundColor Red }
    }
}

if ($BLOCKS_TO_DELETE.Count -eq 0) {
    Write-Host "✅ Page '$PAGE_NAME' already only contains properties" -ForegroundColor Green
    exit 0
}

if ($DEBUG_MODE) { 
    Write-Host "Found $($BLOCKS_TO_DELETE.Count) blocks to delete" -ForegroundColor Red
    Write-Host "Found $($PROPERTIES_BLOCKS_FOUND.Count) properties blocks to keep" -ForegroundColor Cyan
}

# Delete each non-property block
$DELETED_COUNT = 0
foreach ($block in $BLOCKS_TO_DELETE) {
    if ($DEBUG_MODE) { Write-Host "Deleting block: $($block.uuid)" -ForegroundColor Yellow }
    
    $DELETE_RESPONSE = curl -s -X POST "$LOGSEQ_ENDPOINT" `
        -H "Authorization: Bearer $LOGSEQ_TOKEN" `
        -H "Content-Type: application/json" `
        -d "{""method"":""logseq.Editor.removeBlock"",""args"":[""$($block.uuid)""]}" | ConvertFrom-Json
    
    if ($DELETE_RESPONSE -eq $null) {
        $DELETED_COUNT++
        if ($DEBUG_MODE) { Write-Host "Deleted block: $($block.uuid)" -ForegroundColor Green }
    } else {
        if ($DEBUG_MODE) { Write-Host "Failed to delete block: $($block.uuid)" -ForegroundColor Red }
    }
}

if ($DELETED_COUNT -eq $BLOCKS_TO_DELETE.Count) {
    Write-Host "✅ Purged $DELETED_COUNT content blocks from page '$PAGE_NAME' (preserved $($PROPERTIES_BLOCKS_FOUND.Count) property blocks)" -ForegroundColor Green
} else {
    Write-Error "Error: Only deleted $DELETED_COUNT out of $($BLOCKS_TO_DELETE.Count) blocks"
    exit 1
}