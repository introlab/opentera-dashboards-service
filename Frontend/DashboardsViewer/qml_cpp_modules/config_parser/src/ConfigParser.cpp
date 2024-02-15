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
    textStream << "import OpenTeraLibs.UserClient;\n";
    textStream << "import DashboardsViewer;\n";
    textStream << "import content;\n";


    // Write Layout
    QJsonObject layout = json["layout"].toObject();
    //writeLayout(layout, textStream);

    QString type = layout["type"].toString();

    // Start layout
    textStream << type << " {\n";

    // Get Properties
    QJsonObject layoutProperties = layout["properties"].toObject();
    writeProperties(layoutProperties, textStream);



    // Write widgets
    QJsonArray widgets = json["widgets"].toArray();
    qDebug() << "widgets array size: " << widgets.size();
    for (int i = 0; i < widgets.size(); i++)
    {
        QJsonObject widget = widgets[i].toObject();
        writeWidget(widget, textStream);
    }


    // Write connections
    QJsonArray connections = json["connections"].toArray();
    writeConnections(connections, textStream);


    // End layout
    textStream << "}\n";
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

    // Get Properties
    QJsonObject layoutProperties = layout["properties"].toObject();
    writeProperties(layoutProperties, stream);

    // End layout
    stream << "}\n";

}

void ConfigParser::writeWidget(const QJsonObject &widget, QTextStream &stream)
{
    QString type = widget["type"].toString();

    // Start widget
    stream << type << " {\n";

    // Get Properties
    QJsonObject properties = widget["properties"].toObject();
    writeProperties(properties, stream);

    // End widget
    stream << "}\n";
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
            stream << "    " << it.key() << ": \"" << property["value"].toString() << "\";\n";
        }
        else if (type == "raw")
        {
            stream << "    " << it.key() << ": " << property["value"].toString() << ";\n";
        }
        else if (type == "int")
        {
            stream << "    " << it.key() << ": " << property["value"].toInt() << ";\n";
        }
        else if (type == "bool")
        {
            stream << "    " << it.key() << ": " << property["value"].toString() << ";\n";
        }
        else
        {
            qDebug() << "Error: Unknown property type: " << type;
        }

    } // End properties
}

void ConfigParser::writeConnections(const QJsonArray &connections, QTextStream &stream)
{
    // Start connections
    stream << "Connections {\n";

    // Iterate through all connections
    for (auto i = 0; i < connections.size(); i++)
    {
        // Extract each property which is an object with type and value
        QJsonObject connection = connections[i].toObject();

        QJsonObject source = connection["source"].toObject();
        QJsonObject target = connection["target"].toObject();

        QString sourceObject = source["object"].toString();
        QString sourceSignal = source["signal"].toString();
        QString targetObject = target["object"].toString();
        QString targetSlot = target["slot"].toString();

        // Write connection
        stream << "    " << "target: " << sourceObject << ";\n";
        stream << "    " << sourceSignal << ": {" << targetObject << "." << targetSlot << "();}\n";
        stream << "    " << "\n";
    }

    // End connections
    stream << "}\n";
}



