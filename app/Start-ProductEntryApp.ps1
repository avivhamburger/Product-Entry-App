Set-StrictMode -Version 2.0

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$storeScript = Join-Path $projectRoot 'src\ProductEntry.Store.ps1'

. $storeScript

Initialize-ProductEntryStore

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

[System.Windows.Forms.Application]::EnableVisualStyles()

function Set-StatusMessage {
    param(
        [System.Windows.Forms.Label] $Label,
        [string] $Message,
        [System.Drawing.Color] $Color
    )

    $Label.Text = $Message
    $Label.ForeColor = $Color
}

function Refresh-EntryGrid {
    param(
        [System.Windows.Forms.DataGridView] $Grid
    )

    $entries = Get-ProductEntries
    $Grid.DataSource = $null
    $Grid.DataSource = [System.Collections.ArrayList] @($entries)

    foreach ($column in $Grid.Columns) {
        $column.AutoSizeMode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::Fill
    }
}

$form = New-Object System.Windows.Forms.Form
$form.Text = "Te'leaf Accounts Receivable"
$form.StartPosition = 'CenterScreen'
$form.Size = New-Object System.Drawing.Size(920, 620)
$form.MinimumSize = New-Object System.Drawing.Size(820, 540)

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = "Add Purchases from Te'leaf Sales"
$titleLabel.Font = New-Object System.Drawing.Font('Segoe UI', 16, [System.Drawing.FontStyle]::Bold)
$titleLabel.Location = New-Object System.Drawing.Point(18, 16)
$titleLabel.Size = New-Object System.Drawing.Size(360, 34)

$dateLabel = New-Object System.Windows.Forms.Label
$dateLabel.Text = 'Date'
$dateLabel.Location = New-Object System.Drawing.Point(22, 70)
$dateLabel.Size = New-Object System.Drawing.Size(120, 22)

$datePicker = New-Object System.Windows.Forms.DateTimePicker
$datePicker.Format = [System.Windows.Forms.DateTimePickerFormat]::Custom
$datePicker.CustomFormat = 'MM/dd/yyyy'
$datePicker.Value = Get-Date
$datePicker.Location = New-Object System.Drawing.Point(22, 96)
$datePicker.Size = New-Object System.Drawing.Size(95, 28)
$datePicker.RightToLeft = [System.Windows.Forms.RightToLeft]::Yes


$productLabel = New-Object System.Windows.Forms.Label
$productLabel.Text = 'Product Name'
$productLabel.Location = New-Object System.Drawing.Point(150, 70)
$productLabel.Size = New-Object System.Drawing.Size(140, 20)

$productTextBox = New-Object System.Windows.Forms.TextBox
$productTextBox.Location = New-Object System.Drawing.Point(150, 96)
$productTextBox.Size = New-Object System.Drawing.Size(200, 10)

$priceLabel = New-Object System.Windows.Forms.Label
$priceLabel.Text = 'Price'
$priceLabel.Location = New-Object System.Drawing.Point(376, 70)
$priceLabel.Size = New-Object System.Drawing.Size(80, 22)

$priceTextBox = New-Object System.Windows.Forms.TextBox
$priceTextBox.Location = New-Object System.Drawing.Point(376, 96)
$priceTextBox.Size = New-Object System.Drawing.Size(120, 28)

$addButton = New-Object System.Windows.Forms.Button
$addButton.Text = 'Add Entry'
$addButton.Location = New-Object System.Drawing.Point(22, 146)
$addButton.Size = New-Object System.Drawing.Size(118, 34)

$clearButton = New-Object System.Windows.Forms.Button
$clearButton.Text = 'Clear'
$clearButton.Location = New-Object System.Drawing.Point(152, 146)
$clearButton.Size = New-Object System.Drawing.Size(100, 34)

$clearAllButton = New-Object System.Windows.Forms.Button
$clearAllButton.Text = 'Clear All'
$clearAllButton.Location = New-Object System.Drawing.Point(264, 146)
$clearAllButton.Size = New-Object System.Drawing.Size(100, 34)

$exportButton = New-Object System.Windows.Forms.Button
$exportButton.Text = 'Export'
$exportButton.Location = New-Object System.Drawing.Point(376, 146)
$exportButton.Size = New-Object System.Drawing.Size(118, 34)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = ''
$statusLabel.Location = New-Object System.Drawing.Point(22, 194)
$statusLabel.Size = New-Object System.Drawing.Size(840, 24)

$grid = New-Object System.Windows.Forms.DataGridView
$grid.Location = New-Object System.Drawing.Point(22, 230)
$grid.Size = New-Object System.Drawing.Size(842, 312)
$grid.Anchor = (
    [System.Windows.Forms.AnchorStyles]::Top -bor
    [System.Windows.Forms.AnchorStyles]::Bottom -bor
    [System.Windows.Forms.AnchorStyles]::Left -bor
    [System.Windows.Forms.AnchorStyles]::Right
)
$grid.AllowUserToAddRows = $false
$grid.AllowUserToDeleteRows = $false
$grid.ReadOnly = $true
$grid.SelectionMode = [System.Windows.Forms.DataGridViewSelectionMode]::FullRowSelect
$grid.AutoSizeColumnsMode = [System.Windows.Forms.DataGridViewAutoSizeColumnsMode]::Fill

$addButton.Add_Click({
    try {
        $entry = New-ProductEntry `
            -ProductName $productTextBox.Text `
            -PriceText $priceTextBox.Text `
            -Date $datePicker.Value

        Save-ProductEntry -Entry $entry | Out-Null
        Refresh-EntryGrid -Grid $grid
        $productTextBox.Clear()
        $priceTextBox.Clear()
        $productTextBox.Focus()
        Set-StatusMessage -Label $statusLabel -Message 'Entry added.' -Color ([System.Drawing.Color]::ForestGreen)
    }
    catch {
        Set-StatusMessage -Label $statusLabel -Message $_.Exception.Message -Color ([System.Drawing.Color]::Firebrick)
    }
})

$clearButton.Add_Click({
    $datePicker.Value = Get-Date
    $productTextBox.Clear()
    $priceTextBox.Clear()
    Set-StatusMessage -Label $statusLabel -Message '' -Color ([System.Drawing.Color]::Black)
    $productTextBox.Focus()
})

$clearAllButton.Add_Click({
    try {
        Clear-ProductEntries
        Refresh-EntryGrid -Grid $grid
        Set-StatusMessage -Label $statusLabel -Message 'Table cleared.' -Color ([System.Drawing.Color]::ForestGreen)
    }
    catch {
        Set-StatusMessage -Label $statusLabel -Message $_.Exception.Message -Color ([System.Drawing.Color]::Firebrick)
    }
})

$exportButton.Add_Click({
    try {
        $exportPath = Export-ProductEntries
        Set-StatusMessage -Label $statusLabel -Message "Exported to Google Sheet: $exportPath" -Color ([System.Drawing.Color]::ForestGreen)
    }
    catch {
        Set-StatusMessage -Label $statusLabel -Message $_.Exception.Message -Color ([System.Drawing.Color]::Firebrick)
    }
})

$form.Controls.AddRange(@(
    $titleLabel,
    $dateLabel,
    $datePicker,
    $productLabel,
    $productTextBox,
    $priceLabel,
    $priceTextBox,
    $addButton,
    $clearButton,
    $clearAllButton,
    $exportButton,
    $statusLabel,
    $grid
))

$form.Add_FormClosing({
    Clear-ProductEntries
})

Refresh-EntryGrid -Grid $grid

$form.Add_Shown({
    $productTextBox.Select()
    $productTextBox.Focus()
})

[void] $form.ShowDialog()
