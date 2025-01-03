include_guard(GLOBAL)

# Подключаем Qt
if(NOT DEFINED ENV{Qt6_DIR})
	set(ENV{Qt6_DIR} ${SDK_PATH}/Qt/Qt6/6.8.0/msvc2022_64)
endif()

set(Qt6Tools_DIR $ENV{Qt6_DIR}/lib/cmake)
set(Qt6CoreTools_DIR ${Qt6Tools_DIR}/Qt6CoreTools)
set(Qt6GuiTools_DIR ${Qt6Tools_DIR}/Qt6GuiTools)
set(Qt6Translations_DIR $ENV{Qt6_DIR}/translations)

set(QtModules Widgets Xml Network Svg SvgWidgets Concurrent HttpServer)
find_package(Qt6 REQUIRED COMPONENTS ${QtModules})

set(QT_BIN_DIR $ENV{Qt6_DIR}/bin)
set(QT_LRELEASE_TOOL "${QT_BIN_DIR}/lrelease")
set(QT_LUPDATE_TOOL "${QT_BIN_DIR}/lupdate")
set(QT_MOC_TOOL "${QT_BIN_DIR}/moc")
