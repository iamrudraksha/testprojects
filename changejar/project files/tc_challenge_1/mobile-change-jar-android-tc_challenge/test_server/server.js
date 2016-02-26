/*
* Launches a local HTTP server that delegates request to Personality Insights Service 
* Username and password need to be specified (see Development Guide for more info)
*/

// Test server port
var port = 8888

/// Prepare HTTP service
var http = require('http');
var url  = require('url');

/// Sample responses files
var folderName = 'JSON_responses'
// success responses for GET requests
var getResponseFilenames = new Object();
getResponseFilenames['/ideas/'] = folderName + '/ideas.json';

// error responses
var errorFilenames = new Object();
errorFilenames['/ideas/?showError=yes'] = folderName + '/ideas_error.json';

/// file reader
var fs = require('fs');

var nextFreeId = 1000 + Math.floor(Math.random() * 1000)

/// ideas list
var ideasList = []

if (typeof String.prototype.startsWith != 'function') {
    // see below for better implementation!
    String.prototype.startsWith = function (str){
        return this.indexOf(str) === 0;
    };
}

/// function to process the request
var processRequest = function (req, res, postParams) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;
    var json = JSON.parse('{}')
    var filename = '';
    // If need to return error, then use 'errorFilenamesByAPI'
    if (query.showError == "yes") {
        filename = errorFilenames[url_parts.path];
    }
    else {
        if (req.method == "GET") {
            if (url_parts.path.startsWith('/ideas')) {
                filename = getResponseFilenames['/ideas/'];
            }
            else {
                filename = getResponseFilenames[url_parts.path];
            }
        }
        else if (req.method == "POST") {
            json = postParams
            json["ideaId"] = nextFreeId
            console.log("New idea id: " + nextFreeId)
            nextFreeId++
            ideasList.push(json)
        }
    }
    // Read sample file
    if (filename == folderName + '/ideas.json' && ideasList.length > 0) {
        json = ideasList
        console.log("Using cached list of ideas: " + JSON.stringify(json))
    }
    else if (filename) {
        console.log("reading file: " + filename)
        var text = fs.readFileSync(filename);
        json = JSON.parse(text.toString());
        if (filename == folderName + '/ideas.json') {
            ideasList = json
        }
    }
    // Reply
    res.writeHead(200, {'Content-Type': 'application/json'});
    res.end(JSON.stringify(json));
    console.log("JSON: "+JSON.stringify(json))
}



// Start local HTTP server
console.log("Starting local HTTP server...")
http.createServer(function (req, res) {
    var url_parts = url.parse(req.url, true);
    var query = url_parts.query;

    console.log("REQUEST: " + url_parts.path)
    console.log(query);
    var postParams = {}
//    console.log("Headers: " + JSON.stringify(req.headers)); //  UNCOMMENT TO SEE ALL HEADERS IN THE LOG
                  
    // Read PUT parameters
    if (req.method == 'POST') {
        var body = '';
        req.on('data', function (data) {
            body += data;
        });
        req.on('end', function () {
            console.log("BODY: " + body)
            if (req.headers["content-type"] == "application/json") {
               console.log("json post")
                postParams = JSON.parse(body)
            }
            else {
                postParams = url.parse(body, true).query;
            }
            console.log("PUT parameters: " + JSON.stringify(postParams))
            processRequest(req, res, postParams)
        });
    }
    else {
        processRequest(req, res, postParams)
    }
}).listen(port);
console.log("DONE")




