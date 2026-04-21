include_guard(GLOBAL)

get_target_property(QT_QMAKE_EXECUTABLE Qt${QT_MAJOR_VERSION}::qmake IMPORTED_LOCATION)
execute_process(
    COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_BINS OUTPUT_VARIABLE QT_BIN_DIR OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_LIBEXECS OUTPUT_VARIABLE QT_LIB_DIR OUTPUT_STRIP_TRAILING_WHITESPACE
)
execute_process(
    COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_TRANSLATIONS OUTPUT_VARIABLE QT_TRANSLATIONS_DIR OUTPUT_STRIP_TRAILING_WHITESPACE
)

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

function(CopyAndInstallQtModules)
	set(QT_BIN_FILES)
	set(QT_PDB_FILES)

	foreach(lib ${ARGN})
		set(LIB_TARGET Qt${QT_MAJOR_VERSION}::${lib})
		if (NOT TARGET ${LIB_TARGET})
			message(FATAL_ERROR "Cannot find target ${LIB_TARGET} for ${lib} lirary")
		endif()
		get_target_property(lib_location ${LIB_TARGET} LIB_LOCATION)
		message(STATUS "${LIB_TARGET}: ${lib_location}")
		list(APPEND QT_BIN_FILES ${lib_location})

		if (MSVC AND ${CMAKE_BUILD_TYPE} STREQUAL "Debug")
			get_filename_component(lib_path ${lib_location} DIRECTORY)
			get_filename_component(lib_name ${lib_location} NAME_WLE)
			list(APPEND QT_PDB_FILES "${lib_path}/${lib_name}.pdb")
		endif()
	endforeach()

	file(COPY ${QT_BIN_FILES} ${QT_PDB_FILES} DESTINATION ${CMAKE_BINARY_DIR}/bin)
	install(FILES ${QT_BIN_FILES} DESTINATION .)
endfunction()

function(CopyAndInstallQtPlugins)
	foreach(plugin ${ARGN})
		set(PLUGIN_TARGET Qt${QT_MAJOR_VERSION}::${plugin}Plugin)
		if (NOT TARGET ${PLUGIN_TARGET})
			message(FATAL_ERROR "Cannot find target ${PLUGIN_TARGET} for ${plugin} plugin")
		endif()
		get_target_property(plugin_location ${PLUGIN_TARGET} LIB_LOCATION)
		message(STATUS "${PLUGIN_TARGET}: ${plugin_location}")

		get_target_property(plugin_type ${PLUGIN_TARGET} QT_PLUGIN_TYPE)
		file(COPY ${plugin_location} DESTINATION "${CMAKE_BINARY_DIR}/bin/${plugin_type}")
		install(FILES ${plugin_location} DESTINATION ${plugin_type})
	endforeach()
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
		
	file(COPY ${ICU_BIN_FILES} DESTINATION ${CMAKE_BINARY_DIR}/bin)
	install(FILES ${ICU_BIN_FILES} DESTINATION .)
endfunction()

