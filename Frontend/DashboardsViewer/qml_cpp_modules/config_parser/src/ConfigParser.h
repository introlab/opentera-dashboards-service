#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include "qqmlintegration.h"
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>

class ConfigParser : public QObject
{
    Q_OBJECT

public:
    explicit ConfigParser(QObject *parent = nullptr);
    ~ConfigParser() override;

    Q_INVOKABLE bool parseConfig(const QString &configPath);
    Q_INVOKABLE QString get(const QString &key);
    Q_INVOKABLE bool set(const QString &key, const QString &value);
    Q_INVOKABLE bool save(const QString &configPath);


};

#endif
