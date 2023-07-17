include_guard(GLOBAL)

function(MakeSourceGroup)
	set(__options)
	set(__one_val_required
		PROJECT_FULLPATH
		GROUP_NAME
		)
	set(__one_val_optional)
	set(__multi_val
		FILES
		)
	ParseArgumentsWithConditions(ARG "${__options}" "${__one_val_required}" "${__one_val_optional}" "${__multi_val}" ${ARGN} )

	FOREACH( FILE ${ARG_FILES} )
		GET_FILENAME_COMPONENT( FULLPATH ${FILE} ABSOLUTE )
		GET_FILENAME_COMPONENT( FILE_NAME ${FILE} NAME )
		STRING( REPLACE ${FILE_NAME} "" FULLPATH "${FULLPATH}" )
		STRING( REPLACE ${ARG_PROJECT_FULLPATH} "" RELATIVEPATH "${FULLPATH}" )
		STRING( REPLACE "/" "\\" BACKSLASHEDPATH "${RELATIVEPATH}" )
		SOURCE_GROUP( "${ARG_GROUP_NAME}${BACKSLASHEDPATH}" FILES ${FILE} )
	ENDFOREACH()
	
endfunction()

#  Макрос составляет группы исходников аналогично их расположению на диске относительно директории
# ARG_SOURCE_DIR. На входе имеет CURRENT_SOURCES, CURRENT_HEADERS, CURRENT_QML. Применимо для VS.
macro(makeSourceGroups)
	GET_FILENAME_COMPONENT( CURRENT_PROJECT_FULLPATH ${ARG_SOURCE_DIR} ABSOLUTE )

	MakeSourceGroup(
		PROJECT_FULLPATH ${CURRENT_PROJECT_FULLPATH}
		GROUP_NAME "Sources"
		FILES ${CURRENT_SOURCES}
	)
	MakeSourceGroup(
		PROJECT_FULLPATH ${CURRENT_PROJECT_FULLPATH}
		GROUP_NAME "Headers"
		FILES ${CURRENT_HEADERS}
	)
	MakeSourceGroup(
		PROJECT_FULLPATH ${CURRENT_PROJECT_FULLPATH}
		GROUP_NAME "QML"
		FILES ${CURRENT_QML}
	)
	MakeSourceGroup(
		PROJECT_FULLPATH ${CURRENT_PROJECT_FULLPATH}
		GROUP_NAME "Forms"
		FILES ${CURRENT_FORMS}
	)
#	FOREACH(FILE ${CURRENT_RESOURCES} )
#		GET_FILENAME_COMPONENT( FILE_NAME ${FILE} NAME )
#		SOURCE_GROUP( "Resources" FILES ${FILE_NAME} )
#	ENDFOREACH()
endmacro()

function(CreateExportLibFile target definition_name output_file)
	set(TARGET ${target})
	set(DEFINITION_NAME ${definition_name})
	configure_file(${BUILDSCRIPTS_HELPERS_DIR}/ExportLib.h.in ${CMAKE_CURRENT_BINARY_DIR}/export/${output_file} @ONLY)
endfunction()

# Создание новой цели
function(AddTarget)
	set(__options
		STATIC_RUNTIME      # использовать static runtime (/MT) стандартной библиотеки (только MSVC)
		)
	set(__one_val_required
		NAME                # Имя цели, обязательно
		TYPE                # Тип цели shared_lib|static_lib|app|app_console|header_only
		SOURCE_DIR          # Путь к папке с исходниками
		)
	set(__one_val_optional
		PROJECT_GROUP       # Группа проекта, может быть составной "Proc/Codec"
		OUTPUT_NAME         # Задаёт выходное имя таргета
		WIN_APP_ICON        # Путь до иконки приложения (win)
		CXX_STANDARD        # версия С++. 17|20.
		)
	set(__multi_val
		COMPILER_OPTIONS             # дополнительные опции для компилятора
		COMPILE_DEFINITIONS          # дополнительные дефайны препроцессора (без -D)
		EXCLUDE_SOURCES              # регулярное выражение для исключения исходников. E.g. "blabla\\.(cpp|h)"
		INCLUDE_DIRS                 # Дополнительные include
		INCLUDE_LIB_DIRS             # Дополнительные пути для библиотек
		RESOURCE_MODULES             # Зависимые модули ресурсов
		RESOURCE_PACKAGES            # Пакеты дополнительных ресурсов, объявленные при помощи RegisterResource
		MODULES                      # имена подключаемых 3rdparty-модулей. E.g. boost, OpenGLSupport, boost::filesystem, WinLicense, opencv::imgcodecs. Модули могут иметь зависимости - например, boost::filesystem еще и подключает хедеры.
		QT_USE                       # используемые модули Qt.
		LINK_TARGETS                 # зависимые цели для компоновки. E.g. CoreInt.
		LINK_LIBRARIES               # дополнительные библиотеки для компоновк. E.g. [ WIN32 d3d.lib ]
		DEPENDENCIES                 # Указываются другие цели, сборка которых должна происходить раньше этой
		QT_PLUGINS			         # Плагины QT. Например: QWindowsAudio для импортируемой либы Qt6::QWindowsAudioPlugin (См. QT_DIR/lib/cmake/Qt5Multimedia)
		QT_QML_MODULES               # QML плагины
		QRC                          # Дополнительные *.qrc файлы с ресурсами, будут подключены и влинкованы в этот модуль
		FORMS                        # Дополнительные *.ui файлы
		SOURCES                      # Дополнительные файлы с исходниками.
		LINK_FLAGS                   # Флаги компоновки
		CONFIGS                      # Здесь указываются файлы конфигурирующие данное приложение (пресеты, ...)
		WIN_RC                       # Дополнительные *.rc файлы с виндовыми ресурсами, будут подключены и влинкованы в этот модуль
	)
	ParseArgumentsWithConditions(ARG "${__options}" "${__one_val_required}" "${__one_val_optional}" "${__multi_val}" ${ARGN} )
	
	file(GLOB_RECURSE allFiles "${ARG_SOURCE_DIR}/[^.]*" ) # Пропуск скрытых и исключённых файлов
	foreach(exclude ${ARG_EXCLUDE_SOURCES})
		list(FILTER allFiles EXCLUDE REGEX ${exclude})
	endforeach()
	
	set(CURRENT_CMAKES ${allFiles})
	list(FILTER CURRENT_CMAKES INCLUDE REGEX "\\.cmake$")
	set(CURRENT_HEADERS ${allFiles})
	list(FILTER CURRENT_HEADERS INCLUDE REGEX "\\.(h|hpp)$")
	set(CURRENT_SOURCES ${allFiles})
	list(FILTER CURRENT_SOURCES INCLUDE REGEX "\\.(c|cc|cpp)$")
	if(ARG_QT_USE)
		set(CURRENT_QML ${allFiles})
		list(FILTER CURRENT_QML INCLUDE REGEX "\\.(qml|js)$")
		set(CURRENT_FORMS ${allFiles})
		list(FILTER CURRENT_FORMS INCLUDE REGEX "\\.ui$")
		set(CURRENT_RESOURCES ${allFiles})
		list(FILTER CURRENT_RESOURCES INCLUDE REGEX "\\.(qrc)$")
		if (ARG_FORMS)
			list(APPEND CURRENT_FORMS ${ARG_FORMS})
		endif()
		if (ARG_QRC)
			list(APPEND CURRENT_RESOURCES ${ARG_QRC})
		endif()
		foreach(qrc_file ${ARG_QRC})
			message( STATUS "${ARG_NAME}: Using additional qrc: ${qrc_file}" )
			check_if_exists(${qrc_file} "${ARG_NAME}: ${qrc_file} file specified in QRC list not exists")
		endforeach()
	endif()

	if ( WIN32 AND ARG_WIN_APP_ICON)
		set(RC_FILE_NAME "win_resources.rc")
		set(RC_FILE_NAME_APPENDED "${ARG_NAME}/${RC_FILE_NAME}")
		append( CURRENT_SOURCES ${RC_FILE_NAME_APPENDED} )
	endif()

	if (WIN32)
		foreach(rc_file ${ARG_WIN_RC})
			message( STATUS "${ARG_NAME}: Using additional win rc: ${rc_file}" )
			append(CURRENT_SOURCES ${rc_file})
		endforeach()
	endif()

	makeSourceGroups()

	qt_add_resources(RSS_SOURCES ${CURRENT_RESOURCES})
	set(ALL_SOURCES ${CURRENT_SOURCES} ${CURRENT_HEADERS} ${CURRENT_QML} ${CURRENT_FORMS} ${CURRENT_CMAKES} ${RSS_SOURCES} ${ARG_SOURCES} )
	
	set( CreateTarget )
	if(${ARG_TYPE} STREQUAL static_lib)
		set( TargetType STATIC )
		set( CreateTarget "library" )
	elseif(${ARG_TYPE} STREQUAL shared_lib)
		set( TargetType SHARED )
		set( CreateTarget "library" )
		string(TOUPPER "${ARG_NAME}" ProjNameUpperCase)
		CreateExportLibFile( ${ARG_NAME} ${ProjNameUpperCase}_API ${ARG_NAME}Lib.h )
	elseif(${ARG_TYPE} STREQUAL app)
		set( TargetType WIN32 )
		set( CreateTarget "executable" )
	elseif(${ARG_TYPE} STREQUAL app_console)
		set( TargetType "" )
		set( CreateTarget "executable" )
	elseif(${ARG_TYPE} STREQUAL header_only)
		set( TargetType STATIC )
		set( CreateTarget "library" )
	else()
		message( FATAL_ERROR "Unknown target TYPE: ${ARG_TYPE}" )
	endif()

	if(CreateTarget STREQUAL "library")
		qt_add_library( ${ARG_NAME} ${TargetType} ${ALL_SOURCES} )
	elseif(CreateTarget STREQUAL "executable")
		qt_add_executable( ${ARG_NAME} ${TargetType} ${ALL_SOURCES} )
	endif()

	if ( WIN32 AND ARG_WIN_APP_ICON)
		get_target_property(TARGET_OUTPUT_NAME ${ARG_NAME} OUTPUT_NAME)

		#Проверяются переменные, которые должны быть в глобальной области видимости после
		# GrabAllMapVariables(${PRODUCT_CONFIG}Build SEPARATE_COMMA)
		# GrabAllMapVariables(${PRODUCT_CONFIG}CommonSettings PRODUCT_NAME)
		CheckRequiredVariables(
			ORGANIZATION_NAME                 # название организации
			PRODUCT_NAME                      # название продукта
			PRODUCT_NAME_ABOUT                # название продукта в меню "О программе"
			PRODUCT_NAME_FILE_DESCRIPTION     # название продукта отображаемое пользователю в Windows (напр. в меню "Открыть с помощью")
			PRODUCT_NAME_VERSIONED            # навзание продукта с номером версии включительно
			PRODUCT_VERSION_MAJOR             # старшая версия продукта
			PRODUCT_VERSION_MINOR             # младшая версия продукта
			BUILDSCRIPTS_HELPERS_DIR          # путь расположения директории .../buildscripts/scripts/helpers
			ARG_WIN_APP_ICON                  # путь расположения иконки инсталляции
			TARGET_OUTPUT_NAME                # наименование исполняемого файла
		)

		set(APP_ICON ${ARG_WIN_APP_ICON})
		set(RESOURCE_PATH ${BUILDSCRIPTS_HELPERS_DIR}/${RC_FILE_NAME}.in)

		configure_file(${RESOURCE_PATH} ${RC_FILE_NAME_APPENDED})
	endif()

	if(${ARG_TYPE} STREQUAL header_only)
		set(stubFolder ${CMAKE_CURRENT_BINARY_DIR}/stubs)
		file(MAKE_DIRECTORY ${stubFolder})
		configure_file(${BUILDSCRIPTS_HELPERS_DIR}/HeaderOnlyLibraryStub.cpp.in ${stubFolder}/${ARG_NAME}_stub.cpp)
		target_sources(${ARG_NAME} PRIVATE ${stubFolder}/${ARG_NAME}_stub.cpp)
	endif()

	if( ARG_PROJECT_GROUP )
		set_property(TARGET ${ARG_NAME} PROPERTY FOLDER ${ARG_PROJECT_GROUP})
	endif()

	set(LIBS_DEBUG)
	set(LIBS_RELEASE)
	set(DEBUG_ENV "PATH=%PATH%")

	if (ARG_QT_USE)
		string(APPEND DEBUG_ENV ";${QT_BIN_DIR}")
		foreach (module ${ARG_QT_USE})
			find_package(Qt6 REQUIRED COMPONENTS ${module})
			list(APPEND ARG_LINK_TARGETS Qt6::${module})
		endforeach()
	endif()
	
	foreach (module ${ARG_MODULES})
#		if (${module}_LIB_DEBUG)
#			list(APPEND LIBS_DEBUG ${${module}_LIB_DEBUG})
#		endif()
#		if (${module}_LIB_RELEASE)
#			list(APPEND LIBS_RELEASE ${${module}_LIB_RELEASE})
#		endif()
		if (${module}_LIB)
			list(APPEND ARG_LINK_TARGETS ${${module}_LIB})
		endif()
		if (${module}_INCLUDE_DIR)
			list(APPEND ARG_INCLUDE_DIRS ${${module}_INCLUDE_DIR})
		endif()	
#		if (${module}_BIN_DIR)
#			string(APPEND DEBUG_ENV ";${${module}_BIN_DIR}")
#		endif()
	endforeach()

	foreach (lib ${ARG_LINK_TARGETS})
		target_link_libraries(${ARG_NAME} LINK_PRIVATE ${lib})
	endforeach()

	if( ARG_DEPENDENCIES )
		add_dependencies( ${ARG_NAME} ${ARG_DEPENDENCIES})
	endif()

	foreach (lib ${LIBS_DEBUG})
		target_link_libraries(${ARG_NAME} LINK_PRIVATE debug ${lib})
	endforeach()
	
	foreach (lib ${LIBS_RELEASE})
		target_link_libraries(${ARG_NAME} LINK_PRIVATE optimized ${lib})
	endforeach()

	set(INCLUDE_DIRS_ABSOLUTE)
	foreach(dir ${ARG_INCLUDE_DIRS})
		GET_FILENAME_COMPONENT( FULLPATH ${dir} ABSOLUTE )
		list(APPEND INCLUDE_DIRS_ABSOLUTE ${FULLPATH})
	endforeach()
	
	target_include_directories(${ARG_NAME} PRIVATE 
		"${ARG_SOURCE_DIR}"
		${INCLUDE_DIRS_ABSOLUTE}
		${CMAKE_CURRENT_BINARY_DIR}
		${CMAKE_CURRENT_BINARY_DIR}/export
		)

	target_compile_options(${ARG_NAME} PRIVATE ${ARG_COMPILER_OPTIONS})
	target_compile_definitions(${ARG_NAME} PRIVATE ${ARG_COMPILE_DEFINITIONS})
	
	if(ARG_CXX_STANDARD)
		set_target_properties(${ARG_NAME} PROPERTIES CXX_STANDARD ${ARG_CXX_STANDARD})
	endif()
	
	set_target_properties(${ARG_NAME} PROPERTIES VS_DEBUGGER_ENVIRONMENT "${DEBUG_ENV}")
		
#	Print(allFiles: ${allFiles})
	
endfunction()
