Set-StrictMode -Version 2.0

$script:ProjectRoot = Split-Path -Parent $PSScriptRoot
$script:ProductEntries = [System.Collections.Generic.List[psobject]]::new()

function Initialize-ProductEntryStore {
    if ($null -eq $script:ProductEntries) {
        $script:ProductEntries = [System.Collections.Generic.List[psobject]]::new()
    }
}

function ConvertTo-DollarPrice {
    param(
        [Parameter(Mandatory = $true)]
        [string] $PriceText
    )

    $cleanPrice = ($PriceText -replace '[$,\s]', '').Trim()
    $parsedPrice = 0.0

    if (-not [decimal]::TryParse(
        $cleanPrice,
        [System.Globalization.NumberStyles]::Number,
        [System.Globalization.CultureInfo]::InvariantCulture,
        [ref] $parsedPrice
    )) {
        throw 'Enter a valid dollar amount, such as $12.99, 12.99, or 12.'
    }

    if ($parsedPrice -lt 0) {
        throw 'Price cannot be negative.'
    }

    return ('${0:N2}' -f $parsedPrice)
}

function New-ProductEntry {
    param(
        [Parameter(Mandatory = $true)]
        [string] $ProductName,

        [Parameter(Mandatory = $true)]
        [string] $PriceText,

        [datetime] $Date = (Get-Date)
    )

    $trimmedProductName = $ProductName.Trim()

    if ([string]::IsNullOrWhiteSpace($trimmedProductName)) {
        throw 'Product name is required.'
    }

    [pscustomobject] @{
        Date        = $Date.ToString('MM/dd/yyyy')
        ProductName = $trimmedProductName
        Price       = ConvertTo-DollarPrice -PriceText $PriceText
    }
}

function Get-ProductEntries {
    Initialize-ProductEntryStore

    return @($script:ProductEntries)
}

function Save-ProductEntry {
    param(
        [Parameter(Mandatory = $true)]
        [psobject] $Entry
    )

    Initialize-ProductEntryStore

    $script:ProductEntries.Add($Entry)

    return $Entry
}

function Get-AppConfig {
    $configPath = Join-Path $script:ProjectRoot 'config.json'
    if (Test-Path -LiteralPath $configPath) {
        return Get-Content -LiteralPath $configPath -Raw | ConvertFrom-Json
    }
    return $null
}

function Export-ProductEntries {
    param(
        [string] $WebhookUrl,
        [string] $SheetUrl
    )

    Initialize-ProductEntryStore

    # Load from config.json if parameters are not explicitly passed
    if ([string]::IsNullOrWhiteSpace($WebhookUrl) -or [string]::IsNullOrWhiteSpace($SheetUrl)) {
        $config = Get-AppConfig
        if ($config) {
            if ([string]::IsNullOrWhiteSpace($WebhookUrl)) { $WebhookUrl = $config.WebhookUrl }
            if ([string]::IsNullOrWhiteSpace($SheetUrl)) { $SheetUrl = $config.SheetUrl }
        }
    }

    if ([string]::IsNullOrWhiteSpace($WebhookUrl)) {
        throw "Webhook URL is required. Please set WebhookUrl in config.json or pass it as a parameter."
    }

    $entries = @(Get-ProductEntries)

    if ($entries.Count -eq 0) {
        throw "No product entries found to export."
    }

    # Format JSON payload
    $payload = $entries | Select-Object Date, ProductName, Price | ConvertTo-Json -Compress

    # Upload to Google Sheet
    try {
        $response = Invoke-RestMethod -Uri $WebhookUrl -Method Post -Body $payload -ContentType 'application/json; charset=utf-8'
        
        if ($response.status -eq 'success') {
            return $SheetUrl
        }
        else {
            throw $response.message
        }
    }
    catch {
        throw "Failed to upload to Google Sheet: $_"
    }
}

function Clear-ProductEntries {
    Initialize-ProductEntryStore

    $script:ProductEntries.Clear()
}