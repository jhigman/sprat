[![Build Status](https://travis-ci.org/jhigman/sprat.png)](https://travis-ci.org/jhigman/sprat)


Sprat : Spreadsheet API Test Runner
===================================

Write tests for an API in a spreadsheet. Then run the spreadsheet.
------------------------------------------------------------------  

The spreadsheet is in Google Drive, and looks like this:


![Sprat MD5 Test](images/sprat-md5.png)  



The tests are run from the Test Runner menu, and the spreadsheet updated with the results. 

Try the [demo spreadsheet](https://docs.google.com/spreadsheet/ccc?key=0AnNso1xhxP7xdEpmb3prMWdmMEF6Ti05c29TT3R4Q0E#gid=0) (the script will prompt for permissions when invoking the Test Runner for the first time)

Tests can also be queued, and results viewed, from the [Test Runner UI](http://serene-shore-1334.herokuapp.com/jobs).


Running the app
---------------


To run the web app:

	bundle exec rackup config.ru

See the homepage:

	http://localhost:9292


Accessing Google Spreadsheets
-----------------------------

Set some environment variables to give access to Google Spreadsheets:

	GOOGLE_DRIVE_USERNAME=username for google drive spreadsheets account
	GOOGLE_DRIVE_PASSWORD=password for google drive spreadsheets account


Running background jobs
-----------------------

Run a Resque worker process to process background jobs:

	QUEUE=test_jobs bundle exec rake resque:work


Using RedisCloud
----------------

By default, the app will use the local Redis client.

To use a RedisCloud instance, set this environment variable:

	REDISCLOUD_URL=url for redis cloud instance, e.g. redis://rediscloud:1234567890@pub-redis-15001.us-east-1-1.2.ec2.garantiadata.com:15001



Script to run tests from a Google Drive Spreadsheet
---------------------------------------------------


You'll need to add this code to the scripts in the spreadsheet in Google Drive, after which a "Test Runner" menu option will appear:




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
