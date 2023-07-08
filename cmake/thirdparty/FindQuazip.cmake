include(FindPackageHandleStandardArgs)

if(quazip_INCLUDE_DIR AND quazip_LIB_RELEASE AND quazip_LIB_DEBUG)
set(quazip_FIND_QUIETLY TRUE)
endif()

set(quazip_ROOT "${CMAKE_CURRENT_BINARY_DIR}-thirdparty")

find_path(quazip_INCLUDE_DIR quazip.h PATHS "${quazip_ROOT}/include/quazip" REQUIRED)
find_path(quazip_BIN_DIR quazip.dll PATHS "${quazip_ROOT}/bin" REQUIRED)
find_library(quazip_LIB_RELEASE quazip HINTS "${quazip_ROOT}/lib" REQUIRED)
find_library(quazip_LIB_DEBUG quazipd HINTS "${quazip_ROOT}/lib" REQUIRED)

find_package_handle_standard_args(quazip DEFAULT_MSG quazip_INCLUDE_DIR quazip_LIB_RELEASE quazip_LIB_DEBUG)
mark_as_advanced(quazip_LIB)
