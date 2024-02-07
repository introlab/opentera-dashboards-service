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
/*
    QDirIterator it(":/", QDirIterator::Subdirectories);
    while (it.hasNext()) {
        qDebug() << "File:" << it.next();
    }
*/
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





    // iterate through "widgets" array
    QJsonArray widgets = json["widgets"].toArray();

    qDebug() << "widgets array size: " << widgets.size();


    for (int i = 0; i < widgets.size(); i++)
    {

        // Create a QTextStream to operate on the buffer
        QBuffer buffer;
        buffer.open(QIODevice::ReadWrite);
        QTextStream textStream(&buffer);

        // Write import statements
        textStream << "import QtQuick; import OpenTeraLibs.UserClient;\n";

        QJsonObject widget = widgets[i].toObject();
        QString type = widget["type"].toString();

        textStream << type << " {\n";

        // iterate through "properties" array
        QJsonObject properties = widget["properties"].toObject();

        for (auto it = properties.begin(); it != properties.end(); ++it)
        {
            QString key = it.key();
            QJsonValue value = it.value();

            //Output
            if (value.isString() && key != "id")
            {
                textStream << "    " << key << ": \"" << value.toString() << "\";\n";
            }
            else
            {
                textStream << "    " << key << ": " << value.toVariant().toString() << ";\n";
            }

        } // End properties

        // End widget
        textStream << "}\n";
        textStream.seek(0);

        output.append(QVariant(textStream.readAll()));
    }

    //Return all generated widgets in a string list
    return output;
}

