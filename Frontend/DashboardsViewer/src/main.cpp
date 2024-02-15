#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QFontDatabase>
#include <QDebug>

#include "app_environment.h"
#include "import_qml_components_plugins.h"
#include "import_qml_plugins.h"
#include "ConfigParser.h"

#ifdef WEBASSEMBLY
#include <emscripten.h>

#endif

void setupFonts(const QGuiApplication* app){
    int id_font;

    id_font = QFontDatabase::addApplicationFont(":/qt/qml/content/fonts/Arimo-VariableFont_wght.ttf");
    if (id_font == -1){
        qWarning() << "Unable to load Arimo font";
    }

    // Set default font
    QFont defaultFont;
    defaultFont.setFamily("Arimo Regular");
    defaultFont.setPixelSize(18);
    app->setFont(defaultFont);

}

int main(int argc, char *argv[])
{
    set_qt_environment();

    QGuiApplication app(argc, argv);

    QUrl app_url("https://127.0.0.1:40100");

#ifdef WEBASSEMBLY
    char* urlCStr = (char*)EM_ASM_PTR({ return stringToNewUTF8(window.location.href); });

    app_url = QUrl(urlCStr);
    std::free(urlCStr);

    qDebug() << "WebAssembly App running with window.location.href : " << app_url;
#endif

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

    QVariant AppURLVariant = QVariant::fromValue(app_url);
    engine.rootContext()->setContextProperty("AppURL", AppURLVariant);

    // Setup fonts
    setupFonts(&app);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    return app.exec();
}
