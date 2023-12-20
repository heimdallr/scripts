include_guard(GLOBAL)

# Подключаем Qt
if(NOT DEFINED ENV{Qt6_DIR})
	set(ENV{Qt6_DIR} ${SDK_PATH}/Qt/Qt6/6.6.0/msvc2019_64)
endif()

set(Qt6Tools_DIR $ENV{Qt6_DIR}/lib/cmake)
set(Qt6CoreTools_DIR ${Qt6Tools_DIR}/Qt6CoreTools)
set(Qt6GuiTools_DIR ${Qt6Tools_DIR}/Qt6GuiTools)

set(QtModules Widgets Xml Network)
find_package(Qt6 REQUIRED COMPONENTS ${QtModules})

set(icu_modules icudt icuio icuin icuuc)
target_link_libraries(Qt6::Core INTERFACE ${icu_modules})

set(QT_BIN_DIR $ENV{Qt6_DIR}/bin)
set(QT_LRELEASE_TOOL "${QT_BIN_DIR}/lrelease")
set(QT_LUPDATE_TOOL "${QT_BIN_DIR}/lupdate")
set(QT_MOC_TOOL "${QT_BIN_DIR}/moc")
