// Copyright (C) 2021 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR GPL-3.0-only

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDebug>

#include "app_environment.h"
#include "import_qml_components_plugins.h"
#include "import_qml_plugins.h"

#ifdef WEBASSEMBLY
#include <emscripten.h>
#endif

#include "UserClient.h"
#include "QNetworkReplyWrapper.h"

int main(int argc, char *argv[])
{
    set_qt_environment();

    QGuiApplication app(argc, argv);

    QUrl app_url;

#ifdef WEBASSEMBLY
    char* urlCStr = (char*)EM_ASM_PTR({ return stringToNewUTF8(window.location.href); });

    app_url = QUrl(urlCStr);
    std::free(urlCStr);

    qDebug() << "WebAssembly App running with window.location.href : " << app_url;
#endif

    UserClient client;


    qmlRegisterType<QNetworkReplyWrapper>("OpenTera", 1, 0, "NetworkReplyWrapper");

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/qt/qml/Main/main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        },
        Qt::QueuedConnection);

    engine.addImportPath(QCoreApplication::applicationDirPath() + "/qml");
    engine.addImportPath(":/");

    engine.rootContext()->setContextProperty("UserClient", &client);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
