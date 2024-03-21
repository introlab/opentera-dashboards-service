import QtQuick 2.15
import OpenTeraLibs.UserClient 1.0

Item {
    id: baseDataSource
    property string url: "" // Empty URL
    property ListModel model: ListModel {
        id: myModel
    }
    property var params: Object()
    property string fieldIdName: "id_"
    property string fieldDisplayName: "disp_"
    property string iconPath: "qrc:/genericIcon"
    property bool autoFetch: false

    property string sortField: ""
    property int sortType: 0 // 0 = string, 1 = number, 2 = date
    property bool sortDesc: false

    signal error(var errorMessage);
    signal itemSelected(var item);

    function getAll() {
        var reply = UserClient.get(url, params);

        reply.requestSucceeded.connect(function(response, statusCode) {
            //console.log("Success", response, statusCode);

            //Make sure model is empty
            myModel.clear();

            //Print number of elements
            //console.log("Number of elements: ", response.length);

            // Sort items, if needed
            if (sortField){
                response.sort((a, b) => {
                                  let valA, valB;
                                  let orderMult = 1;
                                  if (sortDesc)
                                     orderMult = -1;
                                  if (sortType == 0){
                                        // String sort
                                        valA = a[sortField];
                                        valB = b[sortField];

                                  }
                                  if (sortType == 1){
                                      valA = Number(a[sortField]);
                                      valB = Number(b[sortField]);
                                  }
                                  if (sortType == 2){
                                      valA = new Date(a[sortField]);
                                      valB = new Date(b[sortField]);
                                  }

                                  if (valA < valB) {
                                    return orderMult*-1;
                                  }
                                  if (valA > valB) {
                                    return orderMult*1;
                                  }
                                  return 0;

                              }
                             )
            }

            //Verify if response is an array
            //Add List of items
            if (Array.isArray(response))
            {
                //Insert all elements
                response.forEach(function(item) {
                   item.dataSource = baseDataSource;
                   myModel.append(item);
                });
            }
            else
            {
                //Insert response directly
                response.dataSource = baseDataSource;
                myModel.append(response);
            }
        });

        reply.requestFailed.connect(function(response, statusCode) {
            error(response);
            console.log("Failed", response, statusCode);
        });
    }

    function update() {
        getAll();
    }

    Component.onCompleted: function() {
        //Get data from user client
        if (baseDataSource.autoFetch)
        {
            getAll();
        }
    }
}
