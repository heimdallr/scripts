set(icu_ROOT "${SDK_PATH}/icu/73.2/MSVC2019_64")
string(REPLACE "\\" "/" icu_ROOT ${icu_ROOT})

set(icu_version 73)
set(icu_modules icuio icuin icuuc)

add_library(icudt SHARED IMPORTED)
set_target_properties(icudt PROPERTIES
	# 64
#	INTERFACE_INCLUDE_DIRECTORIES ${icu_ROOT}/include
	IMPORTED_IMPLIB_DEBUG ${icu_ROOT}/lib/icudt.lib
	IMPORTED_IMPLIB_RELEASE ${icu_ROOT}/lib/icudt.lib
	IMPORTED_LOCATION_DEBUG ${icu_ROOT}/bin/icudt${icu_version}.dll
	IMPORTED_LOCATION_RELEASE ${icu_ROOT}/bin/icudt${icu_version}.dll
)

foreach(module ${icu_modules})
	add_library(${module} SHARED IMPORTED)
	set_target_properties(${module} PROPERTIES
		# 64
#		INTERFACE_INCLUDE_DIRECTORIES ${icu_ROOT}/include
		IMPORTED_IMPLIB_DEBUG ${icu_ROOT}/lib/${module}d.lib
		IMPORTED_IMPLIB_RELEASE ${icu_ROOT}/lib/${module}.lib
		IMPORTED_LOCATION_DEBUG ${icu_ROOT}/bin/${module}${icu_version}d.dll
		IMPORTED_LOCATION_RELEASE ${icu_ROOT}/bin/${module}${icu_version}.dll
	)
endforeach()

set(icu_FOUND TRUE)
