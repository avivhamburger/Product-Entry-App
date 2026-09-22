Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$storeScript = Join-Path $projectRoot 'src\ProductEntry.Store.ps1'
$headers = 'Date,ProductName,Price'

. $storeScript

$paths = Get-ProductEntryPaths
$originalStore = if (Test-Path -LiteralPath $paths.EntryStorePath) {
    Get-Content -LiteralPath $paths.EntryStorePath -Raw
}
else {
    $null
}
$originalExport = if (Test-Path -LiteralPath $paths.GoogleDocFeedPath) {
    Get-Content -LiteralPath $paths.GoogleDocFeedPath -Raw
}
else {
    $null
}

try {
    Set-Content -LiteralPath $paths.EntryStorePath -Value $headers -Encoding UTF8
    Set-Content -LiteralPath $paths.GoogleDocFeedPath -Value $headers -Encoding UTF8

    $entry = New-ProductEntry `
        -ProductName 'Widget, "Quoted"' `
        -PriceText '$9.99' `
        -Date ([datetime] '2026-06-01')

    if ($entry.Price -ne '$9.99') {
        throw "Expected price `$9.99, got $($entry.Price)."
    }

    if ($entry.Date -ne '06/01/2026') {
        throw "Expected date 06/01/2026, got $($entry.Date)."
    }

    Save-ProductEntry -Entry $entry | Out-Null

    $entries = @(Get-ProductEntries)
    if ($entries.Count -ne 1) {
        throw "Expected 1 saved entry, got $($entries.Count)."
    }

    $exportPath = Export-ProductEntries
    $exportContent = Get-Content -LiteralPath $exportPath -Raw

    if ($exportContent -notmatch 'Widget, ""Quoted""') {
        throw 'CSV quoting check failed.'
    }

    try {
        New-ProductEntry `
            -ProductName 'Bad Price' `
            -PriceText 'abc' | Out-Null
        throw 'Invalid price was accepted.'
    }
    catch {
        if ($_.Exception.Message -notmatch 'valid dollar') {
            throw
        }
    }

    Clear-ProductEntries
    $entriesAfterClear = @(Get-ProductEntries)
    if ($entriesAfterClear.Count -ne 0) {
        throw "Expected clear page to remove entries, got $($entriesAfterClear.Count)."
    }

    Write-Host 'Backend validation/export checks passed.'
}
finally {
    if ($null -eq $originalStore) {
        Set-Content -LiteralPath $paths.EntryStorePath -Value $headers -Encoding UTF8
    }
    else {
        Set-Content -LiteralPath $paths.EntryStorePath -Value $originalStore -Encoding UTF8
    }

    if ($null -eq $originalExport) {
        Set-Content -LiteralPath $paths.GoogleDocFeedPath -Value $headers -Encoding UTF8
    }
    else {
        Set-Content -LiteralPath $paths.GoogleDocFeedPath -Value $originalExport -Encoding UTF8
    }
}
