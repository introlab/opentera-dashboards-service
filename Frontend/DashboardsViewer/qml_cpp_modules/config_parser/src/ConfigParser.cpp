#include "ConfigParser.h"
#include <QDebug>

ConfigParser::ConfigParser(QObject *parent)
:   QObject(parent)
{

}

ConfigParser::~ConfigParser()
{

}

QString ConfigParser::parseConfig(const QString &configPath)
{
    qDebug() << "ConfigParser::parseConfig() called with configPath: " << configPath;


    //Return generated QML string
    return "import QtQuick; Rectangle { width: 100; height: 100; color: 'red';}";
}

