set(zlib_ROOT "$ENV{THIRDPARTY}/zlib/${PLATFORM}")
string(REPLACE "\\" "/" zlib_ROOT ${zlib_ROOT})

set(ZLIB_LIBRARY "${zlib_ROOT}/lib/zlib.lib")
set(ZLIB_INCLUDE_DIR "${zlib_ROOT}/include")
set(zlib_BIN_DIR "${zlib_ROOT}/bin")
