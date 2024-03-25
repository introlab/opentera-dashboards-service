function fileDownloadFromBrowser(jsonDocumentString)
{
    try {
        //Convert string to JSON object
        var jsonDocument = JSON.parse(jsonDocumentString);

        // do something
        console.log("fileDownloadFromBrowser() called with", jsonDocument);
    }
    catch (e) {
        console.error("fileDownloadFromBrowser() failed with", e);
    }

}