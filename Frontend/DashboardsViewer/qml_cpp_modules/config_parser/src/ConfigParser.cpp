#include "ConfigParser.h"
#include <QDebug>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonValue>
#include <QJsonArray>
#include <QJsonParseError>
#include <QFile>
#include <QDirIterator>
#include <QBuffer>
#include <QTextStream>

ConfigParser::ConfigParser(QObject *parent)
:   QObject(parent)
{

}

ConfigParser::~ConfigParser()
{

}

QVariantList ConfigParser::parseConfig(const QString &configPath)
{
    qDebug() << "ConfigParser::parseConfig() called with configPath: " << configPath;

    //Load JSON file
    QFile file(configPath);
    if (!file.open(QIODevice::ReadOnly))
    {
        qDebug() << "Error: Unable to open file: " << configPath;
        return QVariantList();
    }

    //Read JSON file
    QByteArray data = file.readAll();
    QJsonParseError error;
    QJsonDocument doc = QJsonDocument::fromJson(data, &error);

    qDebug() << "loading document with error : " << error.errorString();
    if (error.error != QJsonParseError::NoError)
    {
        qDebug() << "Error: Unable to parse JSON file: " << configPath;
        return QVariantList();
    }

    QVariantList output;
    QJsonObject json = doc.object();

    // Create a QTextStream to operate on the buffer
    QBuffer buffer;
    buffer.open(QIODevice::ReadWrite);
    QTextStream textStream(&buffer);

    // Write import statements
    textStream << "import QtQuick;\n";
    textStream << "import QtQuick.Controls;\n";
    textStream << "import QtQuick.Layouts;\n";
    textStream << "import OpenTeraLibs.UserClient;\n";
    textStream << "import DashboardsViewer;\n";
    textStream << "import content;\n";

    // Write the root object, make sure it will fill parent
    textStream << "Item { //Begin root object \n";
    textStream << "    id: rootObject;\n";
    textStream << "    anchors.fill: parent;\n";

    // Write Main Layout
    QJsonObject layout = json["layout"].toObject();
    writeLayout(layout, textStream);

    // Write dataSources
    QJsonArray dataSources = json["dataSources"].toArray();
    qDebug() << "data-sources array size: " << dataSources.size();
    writeDataSources(dataSources, textStream);

    // Write connections
    QJsonArray connections = json["connections"].toArray();
    qDebug() << "connections array size: " << connections.size();
    writeConnections(connections, textStream);

    // End root object
    textStream << "} // End Root Object\n";


    textStream.flush();

    // Reset the buffer position to the start of the buffer
    buffer.seek(0);
    // Read the buffer contents into a string
    QString qmlString = buffer.readAll();

    qDebug() << "qmlString: " << qmlString;

    // Add the string to the output list
    output.append(QVariant(qmlString));

    //Return all generated widgets in a string list
    return output;
}

void ConfigParser::writeLayout(const QJsonObject &layout, QTextStream &stream)
{

    QString type = layout["type"].toString();

    // Start layout
    stream << type << " {\n";

    //Verify if we have properties
    if (layout.contains("properties"))
    {
        // Write Properties
        QJsonObject layoutProperties = layout["properties"].toObject();
        writeProperties(layoutProperties, stream);
    }
    else
    {
        qDebug() << "No properties found in layout " << type;
    }

    //Verify if layout contain widgets
    if (layout.contains("widgets"))
    {
        // Write widgets
        QJsonArray layoutWidgets = layout["widgets"].toArray();
        qDebug() << "widgets array size: " << layoutWidgets.size();
        for (int i = 0; i < layoutWidgets.size(); i++)
        {
            QJsonObject myWidget = layoutWidgets[i].toObject();
            writeWidget(myWidget, stream);
        }
    }
    else
    {
        qDebug() << "No widgets found in layout " << type;
    }

    //Verify if layout contain layouts
    if (layout.contains("layouts"))
    {
        // Write layouts
        QJsonArray layoutLayouts = layout["layouts"].toArray();
        qDebug() << "layouts array size: " << layoutLayouts.size();
        for (int i = 0; i < layoutLayouts.size(); i++)
        {
            QJsonObject myLayout = layoutLayouts[i].toObject();
            writeLayout(myLayout, stream);
        }
    }
    else
    {
        qDebug() << "No layouts found in layout " << type;
    }

    // End layout
    stream << "} //End Layout of type " << type << "\n";

}


void ConfigParser::writeWidget(const QJsonObject &widget, QTextStream &stream)
{
    QString type = widget["type"].toString();

    // Start widget
    stream << type << " {\n";

    // Get Properties
    QJsonObject properties = widget["properties"].toObject();
    qDebug() << "properties size for widget: " << properties.size();
    writeProperties(properties, stream);

    // End widget
    stream << "} //End Widget\n";
}

void ConfigParser::writeProperties(const QJsonObject &properties, QTextStream &stream)
{
    //TODO Support more types
    // Iterate through all properties
    for (auto it = properties.begin(); it != properties.end(); ++it)
    {
        // Extract each property which is an object with type and value
        QJsonObject property = it.value().toObject();

        QString type = property["type"].toString();

        if (type == "string")
        {
            stream << "    " << it.key() << ": \"" << property["value"].toString() << "\"\n";
        }
        else if (type == "raw")
        {
            stream << "    " << it.key() << ": " << property["value"].toString() << "\n";
        }
        else if (type == "int")
        {
            stream << "    " << it.key() << ": " << property["value"].toInt() << "\n";
        }
        else if (type == "bool")
        {
            stream << "    " << it.key() << ": " << property["value"].toString() << "\n";
        }
        else if (type == "delegate")
        {
            stream << "    " << it.key() << ": " << property["value"].toString() << "{}\n";
        }
        else
        {
            qDebug() << "Error: Unknown property type: " << type;
        }

    } // End properties
}



void ConfigParser::writeConnections(const QJsonArray &connections, QTextStream &stream)
{


    // Iterate through all connections
    for (auto i = 0; i < connections.size(); i++)
    {
        // Start connections
        stream << "Connections {\n";

        // Extract connection information
        QJsonObject connection = connections[i].toObject();

        QJsonObject source = connection["source"].toObject();
        QJsonObject target = connection["target"].toObject();

        QString sourceObject = source["object"].toString();
        QString sourceSignal = source["signal"].toString();
        QString targetObject = target["object"].toString();
        QString targetSlot = target["slot"].toString();

        // Write connection
        stream << "    " << "target: " << sourceObject << ";\n";
        stream << "    " << sourceSignal << ": function (";
        // Write arguments
        QJsonArray arguments = target["args"].toArray();
        for (auto j = 0; j < arguments.size(); j++)
        {
            stream << arguments[j].toString();
            if (j < arguments.size() - 1)
            {
                stream << ", ";
            }
        }

        stream << "){" << targetObject << "." << targetSlot << "(";

        // Write arguments (again)
        for (auto j = 0; j < arguments.size(); j++)
        {
            stream << arguments[j].toString();
            if (j < arguments.size() - 1)
            {
                stream << ", ";
            }
        }
        stream <<");}\n";

        stream << "    " << "\n";

        // End connections
        stream << "} // End Connections \n";
    }


}

void ConfigParser::writeDataSources(const QJsonArray &dataSources, QTextStream &stream)
{
    // Iterate through all connections
    for (auto i = 0; i < dataSources.size(); i++)
    {
        // Extract data-source information
        QJsonObject source = dataSources[i].toObject();
        stream << source["type"].toString() <<" {\n";
        QJsonObject properties = source["properties"].toObject();
        writeProperties(properties, stream);
        stream << "}\n";
    }
}



