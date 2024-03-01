#ifndef CONFIG_PARSER_H
#define CONFIG_PARSER_H

#include "qqmlintegration.h"
#include <QObject>
#include <QJsonObject>
#include <QJsonDocument>
#include <QBuffer>
#include <QTextStream>

class ConfigParser : public QObject
{
    Q_OBJECT
    QML_ELEMENT

public:
    explicit ConfigParser(QObject *parent = nullptr);
    ~ConfigParser() override;

    Q_INVOKABLE QVariantList parseConfig(const QString &configPath);


private:
    bool isValidString(const QString &input);
    void writeLayout(const QJsonObject &layout, QTextStream &stream);
    void writeWidget(const QJsonObject &widget, QTextStream &stream);
    void writeProperties(const QJsonObject &properties, QTextStream &stream);
    void writeConnections(const QJsonArray &connections, QTextStream &stream);
    void writeDataSources(const QJsonArray &dataSources, QTextStream &stream);
};

#endif
