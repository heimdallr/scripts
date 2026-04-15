include_guard(GLOBAL)

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

function(CopyAndInstallQt)
	set(D)
	if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		set(D d)
	endif()

	set(QT_BIN_FILES)
	set(QT_PDB_FILES)

	foreach(lib ${ARGN})
		set(lib_base_file_name "${QT_ROOT}/bin/Qt${QT_MAJOR_VERSION}${lib}${D}")
		list(APPEND QT_BIN_FILES ${lib_base_file_name}.dll)
		if (${CMAKE_BUILD_TYPE} STREQUAL "Debug")
			list(APPEND QT_PDB_FILES ${lib_base_file_name}.pdb)
		endif()
	endforeach()

	file(COPY ${QT_BIN_FILES} ${QT_PDB_FILES} DESTINATION ${CMAKE_BINARY_DIR}/bin)

	if (${CMAKE_BUILD_TYPE} STREQUAL "Release")
		install(FILES ${QT_BIN_FILES} DESTINATION .)
	endif()	
endfunction()

function(InstallQtPlugins)
	if (${CMAKE_BUILD_TYPE} STREQUAL "Release")
		foreach(plugin ${ARGN})
			install(DIRECTORY ${CMAKE_BINARY_DIR}/bin/${plugin} DESTINATION .)
		endforeach()
	endif()	
endfunction()

function(CopyAndInstallICU)
	set(LIBS tu data uc i18n)
	if (WIN32)
		set(LIBS tu dt uc in)
	endif()

	set(D)
	if (WIN32 AND ${CMAKE_BUILD_TYPE} STREQUAL "Debug")
		set(D d)
	endif()

	string(REPLACE "." ";" ICU_VERSION_LIST ${ICU_VERSION_STRING})
	list(GET ICU_VERSION_LIST 0 ICU_MAJOR_VERSION)

	string(TOUPPER ${CMAKE_BUILD_TYPE} CMAKE_BUILD_TYPE_UPPER)
	set(ICU_BIN_DIR ${icu_BIN_DIRS_${CMAKE_BUILD_TYPE_UPPER}})
	set(ICU_LIB_DIR ${icu_LIB_DIRS_${CMAKE_BUILD_TYPE_UPPER}})
	set(ICU_BIN_FILES)

	foreach(lib ${LIBS})
		if (WIN32)
			list(APPEND ICU_BIN_FILES ${ICU_BIN_DIR}/icu${lib}${D}${ICU_MAJOR_VERSION}.dll)
		else()
			list(APPEND ICU_BIN_FILES ${ICU_LIB_DIR}/libicu${lib}.so.${ICU_VERSION_STRING})
			list(APPEND ICU_BIN_FILES ${ICU_LIB_DIR}/libicu${lib}.so.${ICU_MAJOR_VERSION})
		endif()
	endforeach()
		
	if (WIN32)
		file(COPY ${ICU_BIN_FILES} DESTINATION ${CMAKE_BINARY_DIR}/bin)
	else()
		file(COPY ${ICU_BIN_FILES} DESTINATION ${CMAKE_BINARY_DIR}/lib)
	endif()
	
	if (${CMAKE_BUILD_TYPE} STREQUAL "Release")
		if (WIN32)
			install(FILES ${ICU_BIN_FILES} DESTINATION .)
		else()
			install(FILES ${ICU_BIN_FILES} DESTINATION ./lib)
		endif()
	endif()	
endfunction()

