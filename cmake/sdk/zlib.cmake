set(zlib_ROOT "${SDK_PATH}/zlib/x64")
string(REPLACE "\\" "/" zlib_ROOT ${zlib_ROOT})

set(ZLIB_LIBRARY "${zlib_ROOT}/lib/zlib.lib")
set(ZLIB_INCLUDE_DIR "${zlib_ROOT}/include")
set(zlib_BIN_DIR "${zlib_ROOT}/bin")

add_library(ZLIB::ZLIB SHARED IMPORTED)
set_target_properties(ZLIB::ZLIB PROPERTIES
        # 64
        INTERFACE_INCLUDE_DIRECTORIES ${ZLIB_INCLUDE_DIR}
        IMPORTED_IMPLIB_DEBUG ${zlib_ROOT}/lib/zlibd.lib
        IMPORTED_IMPLIB_RELEASE ${zlib_ROOT}/lib/zlib.lib
        IMPORTED_LOCATION_DEBUG ${zlib_BIN_DIR}/zlibd.dll
        IMPORTED_LOCATION_RELEASE ${zlib_BIN_DIR}/zlib.dll
)

set(zlib_FOUND TRUE)
