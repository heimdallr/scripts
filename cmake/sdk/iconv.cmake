set(iconv_ROOT "${SDK_PATH}/iconv")
string(REPLACE "\\" "/" icu_ROOT ${iconv_ROOT})

add_library(iconv SHARED IMPORTED)
set_target_properties(iconv PROPERTIES
	# 64
	INTERFACE_INCLUDE_DIRECTORIES ${iconv_ROOT}/include
	IMPORTED_IMPLIB_DEBUG ${iconv_ROOT}/lib/libiconvd.lib
	IMPORTED_IMPLIB_RELEASE ${iconv_ROOT}/lib/libiconv.lib
	IMPORTED_LOCATION_DEBUG ${iconv_ROOT}/bin/libiconvd.dll
	IMPORTED_LOCATION_RELEASE ${iconv_ROOT}/bin/libiconv.dll
)
set(iconv_FOUND TRUE)
