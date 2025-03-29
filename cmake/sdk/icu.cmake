set(icu_ROOT "${SDK_PATH}/icu/77.1/msvc2022_64")
string(REPLACE "\\" "/" icu_ROOT ${icu_ROOT})

set(icu_version 77)
set(icu_modules icudt icuio icuin icuuc)

foreach(module ${icu_modules})
	add_library(${module} SHARED IMPORTED)
	set_target_properties(${module} PROPERTIES
		# 64
		INTERFACE_INCLUDE_DIRECTORIES ${icu_ROOT}/include
		IMPORTED_IMPLIB_DEBUG ${icu_ROOT}/lib64/${module}.lib
		IMPORTED_IMPLIB_RELEASE ${icu_ROOT}/lib64/${module}.lib
		IMPORTED_LOCATION_DEBUG ${icu_ROOT}/bin64/${module}${icu_version}.dll
		IMPORTED_LOCATION_RELEASE ${icu_ROOT}/bin64/${module}${icu_version}.dll
	)
endforeach()

set(icu_FOUND TRUE)
