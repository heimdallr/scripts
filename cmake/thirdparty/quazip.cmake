set(quazip_ROOT "$ENV{THIRDPARTY}/quazip/${PLATFORM}")
set(CMAKE_MODULE_PATH "${quazip_ROOT}/lib/cmake/QuaZip-Qt6-1.4" ${CMAKE_MODULE_PATH})
set(CMAKE_PREFIX_PATH "${quazip_ROOT}/lib/cmake/QuaZip-Qt6-1.4" ${CMAKE_PREFIX_PATH})

find_package(QuaZip-Qt6)
set(quazip_LIB "QuaZip::QuaZip")
