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

set(LIB_INSTALL_DESTINATION lib)
set(LIB_DESTINATION ${CMAKE_BINARY_DIR}/lib)
if(WIN32)
	set(LIB_INSTALL_DESTINATION .)
	set(LIB_DESTINATION ${CMAKE_BINARY_DIR}/bin)
endif()

include(${CMAKE_CURRENT_LIST_DIR}/utils.cmake)

function(CopyAndInstallQtModules)
	set(QT_BIN_FILES)
	set(QT_PDB_FILES)

	foreach(lib ${ARGN})
		set(lib_target Qt${QT_MAJOR_VERSION}::${lib})
		if (NOT TARGET ${lib_target})
			message(FATAL_ERROR "Cannot find target ${lib_target} for ${lib} lirary")
		endif()

		get_target_property(lib_location ${lib_target} LIB_LOCATION)
		message(STATUS "${lib}: ${lib_target} -> ${lib_location}")
		list(APPEND QT_BIN_FILES ${lib_location})
		
		get_filename_component(lib_path ${lib_location} DIRECTORY)
		get_filename_component(lib_name ${lib_location} NAME_WLE)

		if (NOT WIN32)
			get_filename_component(lib_name ${lib_name} NAME_WLE)
			list(APPEND QT_BIN_FILES "${lib_path}/${lib_name}")
			get_filename_component(lib_name ${lib_name} NAME_WLE)
			list(APPEND QT_BIN_FILES "${lib_path}/${lib_name}")
		endif()

		if (MSVC AND ${CMAKE_BUILD_TYPE} STREQUAL "Debug")
			list(APPEND QT_PDB_FILES "${lib_path}/${lib_name}.pdb")
		endif()
	endforeach()

	if(WIN32)
		file(COPY ${QT_BIN_FILES} ${QT_PDB_FILES} DESTINATION ${LIB_DESTINATION})
	endif()
	install(FILES ${QT_BIN_FILES} DESTINATION ${LIB_INSTALL_DESTINATION})
endfunction()

function(CopyAndInstallQtPlugins)
	foreach(plugin ${ARGN})
		set(plugin_target "Qt${QT_MAJOR_VERSION}::${plugin}Plugin")
		if (NOT TARGET ${plugin_target})
			message(WARNING "Cannot find target ${plugin_target} for ${plugin} plugin")
		else()
			get_target_property(plugin_location ${plugin_target} LIB_LOCATION)
			get_filename_component(plugin_directory ${plugin_location} DIRECTORY)
			get_filename_component(plugin_type ${plugin_directory} NAME)

			message(STATUS "${plugin}: ${plugin_type}/${plugin_target} -> ${plugin_location}")
		
			file(COPY ${plugin_location} DESTINATION "${CMAKE_BINARY_DIR}/bin/${plugin_type}")
			install(FILES ${plugin_location} DESTINATION "${plugin_type}")
		endif()
	endforeach()
endfunction()

function(CopyAndInstallICU)
	set(LIBS tu data uc i18n io)
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
	set(ICU_BIN_FILES "${icu_RES_DIRS_${CMAKE_BUILD_TYPE_UPPER}}/icudt${ICU_MAJOR_VERSION}l.dat")

	foreach(lib ${LIBS})
		if (WIN32)
			list(APPEND ICU_BIN_FILES ${ICU_BIN_DIR}/icu${lib}${D}${ICU_MAJOR_VERSION}.dll)
		else()
			list(APPEND ICU_BIN_FILES ${ICU_LIB_DIR}/libicu${lib}.so.${ICU_VERSION_STRING})
			list(APPEND ICU_BIN_FILES ${ICU_LIB_DIR}/libicu${lib}.so.${ICU_MAJOR_VERSION})
		endif()
	endforeach()
		
	file(COPY ${ICU_BIN_FILES} DESTINATION ${LIB_DESTINATION})
	install(FILES ${ICU_BIN_FILES} DESTINATION ${LIB_INSTALL_DESTINATION})
endfunction()

