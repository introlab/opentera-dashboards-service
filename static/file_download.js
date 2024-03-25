function fileDownloadFromBrowser(jsonDocumentString)
{
    /*
    jsonDocumentString: JSON string
    Format:
    {
        "url": "full url with params",
        "method": "GET/POST",
        "headers":  Object with key-value pairs
    }
    */


    try {
        //Convert string to JSON object
        var jsonDocument = JSON.parse(jsonDocumentString);

        //Create AJAX request with the given method, url and headers
        var xhr = new XMLHttpRequest();
        xhr.open(jsonDocument.method, jsonDocument.url, true); //async
        for (var key in jsonDocument.headers) {
            xhr.setRequestHeader(key, jsonDocument.headers[key]);
        }
        xhr.responseType = 'blob';
        
        //On load, download the file
        xhr.onload = function () {
            if (xhr.status === 200) {
                var contentType = xhr.getResponseHeader('Content-Type');
                var blob = new Blob([xhr.response], { type: contentType });
                var url = URL.createObjectURL(blob);
                var a = document.createElement('a');
                a.href = url;
                a.download = "downloaded_file";
                a.click();
                window.URL.revokeObjectURL(url);
            }
            else {
                console.error("fileDownloadFromBrowser() failed with", xhr.status);
            }
        };

        //Send the request
        xhr.send();

        // do something
        console.log("fileDownloadFromBrowser() called with", jsonDocument);
    }
    catch (e) {
        console.error("fileDownloadFromBrowser() failed with", e);
    }

}