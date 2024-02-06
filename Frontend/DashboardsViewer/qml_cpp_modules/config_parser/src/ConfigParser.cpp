#include "ConfigParser.h"
#include <QDebug>

ConfigParser::ConfigParser(QObject *parent)
:   QObject(parent)
{

}

ConfigParser::~ConfigParser()
{

}

bool ConfigParser::parseConfig(const QString &configPath)
{
    qDebug() << "ConfigParser::parseConfig() called with configPath: " << configPath;
    return false;
}

QString ConfigParser::get(const QString &key)
{
    Q_UNUSED(key)
    return QString();
}

bool ConfigParser::set(const QString &key, const QString &value)
{
    Q_UNUSED(key)
    Q_UNUSED(value)
    return false;
}

bool ConfigParser::save(const QString &configPath)
{
    Q_UNUSED(configPath)
    return false;
}
