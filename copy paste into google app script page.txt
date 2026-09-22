function doPost(e) {
  try {
    var spreadsheetId = "YOUR_SPREADSHEET_ID_HERE";
    var targetGid = "YOUR_TARGET_GID_HERE";
    
    var ss = SpreadsheetApp.openById(spreadsheetId);
    var sheets = ss.getSheets();
    var sheet = null;
    
    for (var i = 0; i < sheets.length; i++) {
      if (sheets[i].getSheetId() === targetGid) {
        sheet = sheets[i];
        break;
      }
    }
    
    if (!sheet) {
      sheet = ss.getActiveSheet();
    }

    var data = JSON.parse(e.postData.contents);
    if (!Array.isArray(data)) {
      data = [data];
    }

    data.forEach(function(item) {
      sheet.appendRow([item.Date, item.ProductName, item.Price]);
    });

    return ContentService.createTextOutput(JSON.stringify({ "status": "success", "count": data.length }))
      .setMimeType(ContentService.MimeType.JSON);
  } catch (err) {
    return ContentService.createTextOutput(JSON.stringify({ "status": "error", "message": err.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}