#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include "qqmlintegration.h"
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

class ConfigParser : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ConfigParser(QObject *parent = nullptr);
    ~ConfigParser() override;

    Q_INVOKABLE QVariantList parseConfig(const QString &configPath);



};

#endif
