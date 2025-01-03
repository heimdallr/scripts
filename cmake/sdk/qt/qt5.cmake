include_guard(GLOBAL)

# Подключаем Qt
if(NOT DEFINED ENV{Qt5_DIR})
	set(ENV{Qt5_DIR} ${SDK_PATH}/Qt/Qt5/5.15.2/msvc2019_64)
endif()

set(Qt5Tools_DIR $ENV{Qt5_DIR}/lib/cmake)
set(Qt5Core_DIR ${Qt5Tools_DIR}/Qt5Core)
set(Qt5Gui_DIR ${Qt5Tools_DIR}/Qt5Gui)
set(Qt5Translations_DIR $ENV{Qt5_DIR}/translations)

set(QtModules Widgets Xml Network Svg Concurrent)
find_package(Qt5 REQUIRED COMPONENTS ${QtModules})

set(QT_BIN_DIR $ENV{Qt5_DIR}/bin)
set(QT_LRELEASE_TOOL "${QT_BIN_DIR}/lrelease")
set(QT_LUPDATE_TOOL "${QT_BIN_DIR}/lupdate")
set(QT_MOC_TOOL "${QT_BIN_DIR}/moc")
