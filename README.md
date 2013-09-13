Sprat : Spreadsheet API Test Runner
===================================

*Not ready for use yet.*

Requires some environment variables:

	GOOGLE_DRIVE_USERNAME=username for google drive spreadsheets account
	GOOGLE_DRIVE_PASSWORD=password for google drive spreadsheets account

	REDISCLOUD_URL=url for redis cloud instance, e.g. redis://rediscloud:1234567890@pub-redis-15001.us-east-1-1.2.ec2.garantiadata.com:15001
  

Requires redis running at least one test_jobs queue worker, e.g: `env QUEUE=test_jobs bundle exec rake resque:work`



Running tests from a Google Drive Spreadsheet
=============================================

The spreadsheet containing tests can be hosted on Google Drive, and the test run can be triggered from the spreadsheet. 

Results from the result are then injected back into the spreadsheet, so users can work entirely in the spreadsheet.

You'll need to add this code to the scripts in the spreadsheet, after which a "Test Runner" menu option will appear:




	function onOpen() {
	  var ss = SpreadsheetApp.getActiveSpreadsheet();
	  var menuEntries = [ {name: "Run tests", functionName: "scheduleTestJob"} ];
	  ss.addMenu("Test Runner", menuEntries);
	}

	function getConfigValue(name) {
	  var ws = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
	  var values = ws.getDataRange().getValues();
	  for(n=0;n<values.length;++n){
	    if (values[n][0] == name) {
	      return values[n][1];
	    }
	  }
	  return null;
	}

	function setConfigValue(name, value) {
	  var ws = SpreadsheetApp.getActiveSpreadsheet().getActiveSheet();
	  var values = ws.getDataRange().getValues();
	  for(n=0;n<values.length;++n){
	    if (values[n][0] == name) {
	      ws.getRange(n+1,2).setValue(value);
	    }
	  }
	}

	function scheduleTestJob() {

	  setConfigValue('Status', 'Scheduling..');
	  SpreadsheetApp.flush();
	  
	  var ss = SpreadsheetApp.getActiveSpreadsheet();
	  var ws = ss.getActiveSheet();
	  
	  var ssName = ss.getName();
	  var wsName = ws.getName();
	  
	  var payload =
	      {
	        "spreadsheet" : ssName,
	        "worksheet" : wsName
	      };

	  var options =
	     {
	       "method" : "POST",
	       "payload" : payload
	     };
	  
	  if (getConfigValue('Test Runner Auth')) {
	    var unamepass = getConfigValue('Test Runner Auth');
	    var digest = Utilities.base64Encode(unamepass);
	    var digestfull = "Basic " + digest;
	    options["headers"] = {'Authorization': digestfull}
	  }
	  
	  var testRunnerURL = getConfigValue('Test Runner');
	  
	  var response= UrlFetchApp.fetch(testRunnerURL, options);
	  var content = response.getContentText();

	  setConfigValue('Status', 'Scheduled');

	  SpreadsheetApp.flush();
	}




## Authors

**Julian Higman**

+ [http://twitter.com/jhigman](http://twitter.com/jhigman)
+ [http://github.com/jhigman](http://github.com/jhigman)

**Matt Law**

+ [http://twitter.com/staringskyward](http://twitter.com/staringskyward)
+ [http://github.com/staringskyward](http://github.com/staringskyward)

## Copyright and license

Copyright (c) 2013 Julian Higman and Matthew Law.

See {file:LICENSE.txt} for license information.
