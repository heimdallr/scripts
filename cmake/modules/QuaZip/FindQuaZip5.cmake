set(quazip_ROOT "${SDK_PATH}/quazip/Qt5/x64")
string(REPLACE "\\" "/" quazip_ROOT ${quazip_ROOT})

set(CMAKE_MODULE_PATH "${quazip_ROOT}/lib/cmake/QuaZip-Qt5-1.4" ${CMAKE_MODULE_PATH})
set(CMAKE_PREFIX_PATH "${quazip_ROOT}/lib/cmake/QuaZip-Qt5-1.4" ${CMAKE_PREFIX_PATH})

find_package(QuaZip-Qt5)
set(quazip_LIB "QuaZip::QuaZip")
set(quazip_BIN_DIR "${quazip_ROOT}/bin")

add_library(QuaZip SHARED IMPORTED)
set_target_properties(QuaZip PROPERTIES
        # 64
        INTERFACE_INCLUDE_DIRECTORIES ${quazip_ROOT}/include
        IMPORTED_IMPLIB_DEBUG ${quazip_ROOT}/lib/quazip1-qt5d.lib
        IMPORTED_IMPLIB_RELEASE ${quazip_ROOT}/lib/quazip1-qt5.lib
        IMPORTED_LOCATION_DEBUG ${quazip_ROOT}/bin/quazip1-qt5d.dll
        IMPORTED_LOCATION_RELEASE ${quazip_ROOT}/bin/quazip1-qt5.dll
)
set_target_properties(QuaZip PROPERTIES
	INTERFACE_LINK_LIBRARIES zlib
)

set(QuaZip_FOUND TRUE)
