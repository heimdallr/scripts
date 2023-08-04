set(ICU_ROOT_PATH $ENV{ICU_DIR})
string(REPLACE "\\" "/" ICU_ROOT_PATH ${ICU_ROOT_PATH})
set(ICU_BIN_PATH ${ICU_ROOT_PATH}/bin)
set(ENV{PATH} "$ENV{PATH};${ICU_BIN_PATH}")
AddBinDirectory(${ICU_BIN_PATH})

set(QT_ROOT_PATH $ENV{QT_DIR})
string(REPLACE "\\" "/" QT_ROOT_PATH ${QT_ROOT_PATH})

set(Qt6_DIR "${QT_ROOT_PATH}/lib/cmake/Qt6")
set(QT_BIN_DIR "${QT_ROOT_PATH}/bin")
set(QT_LRELEASE_TOOL "${QT_BIN_DIR}/lrelease")
set(QT_LUPDATE_TOOL "${QT_BIN_DIR}/lupdate")
set(QT_MOC_EXECUTABLE "${QT_BIN_DIR}/moc")

set(CMAKE_PREFIX_PATH ${QT_ROOT_PATH} ${CMAKE_PREFIX_PATH})
set(CMAKE_MODULE_PATH ${QT_ROOT_PATH} ${CMAKE_MODULE_PATH})

SOURCE_GROUP( "Generated Files\\moc" REGULAR_EXPRESSION "moc_.*" )
SOURCE_GROUP( "Generated Files\\ui"  REGULAR_EXPRESSION "ui_.*" )
SOURCE_GROUP( "Generated Files\\qrc" REGULAR_EXPRESSION "qrc_.*" )
SOURCE_GROUP( "Resource Files\\qrc"  REGULAR_EXPRESSION ".*\\.qrc" )
SOURCE_GROUP( "Resource Files\\ts"   REGULAR_EXPRESSION ".*\\.ts" )
SOURCE_GROUP( "Resource Files\\qm"   REGULAR_EXPRESSION ".*\\.qm" )
SOURCE_GROUP( "Resource Files\\mopo"   REGULAR_EXPRESSION ".*\\.mo|.*\\.po")

find_package(Qt6 REQUIRED COMPONENTS Core5Compat)

configure_file(${BUILDSCRIPTS_HELPERS_DIR}/MocWrapper.cmake.in ${CMAKE_BINARY_DIR}/MocWrapper.cmake @ONLY)

AddBinDirectory(${QT_BIN_DIR})
