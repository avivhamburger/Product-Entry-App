# PowerShell Product Entry & Google Sheets Exporter

A lightweight Windows PowerShell GUI app built with WPF to record product price entries locally and push data directly to Google Sheets via Google Apps Script.

## Features
- **GUI Interface:** Runs silently on Windows via VBScript or Batch launcher.
- **Local Persistence:** Saves product records locally in CSV format.
- **Google Sheets Integration:** Appends data to specific worksheet tabs without overwriting existing rows.
- **Automated Tests:** Includes Pester test suites for backend data store operations.

## Requirements

- Windows
- Windows PowerShell 5.1
- No SDK, Node, Python, or Google API setup is required for this version.
## Setup Instructions

### 1. Configuration
1. Clone the repository:
   ```bash
   git clone [https://github.com/YOUR-USERNAME/product-entry-app.git](https://github.com/YOUR-USERNAME/product-entry-app.git)
   cd product-entry-app

## Run the App

Easiest option:

1. Double-click `Run Product Entry App.vbs`.
2. If Windows asks whether to run it, choose `Run`.


Each row contains:

- `Date`
- `ProductName`
- `Price`

## Google Docs / Sheets Handoff

Use the `Export` button, then open your google sheet



## Validation Rules

- Product name is required.
- Price accepts values such as `$12.99`, `12.99`, or `12`.
- Price is saved in dollar format with two decimals.
- Product names with commas or quotes are safely exported as CSV.
- `Clear All` clears the visible table and CSV files.
- Closing the program clears the page automatically.

