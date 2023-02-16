set(QT_ROOT_PATH $ENV{QT_DIR64})
string(REPLACE "\\" "/" QT_ROOT_PATH ${QT_ROOT_PATH})

set(LRELEASE_TOOL "${QT_ROOT_PATH}/bin/lrelease")
set(LUPDATE_TOOL "${QT_ROOT_PATH}/bin/lupdate")

set(CMAKE_PREFIX_PATH ${QT_ROOT_PATH} ${CMAKE_PREFIX_PATH})
set(CMAKE_MODULE_PATH ${QT_ROOT_PATH} ${CMAKE_MODULE_PATH})

set(qt5Modules
	Concurrent
	Core
	Gui
	Multimedia
	Network
	LinguistTools
	OpenGL
	PrintSupport
	Qml
	QmlModels
	QmlWorkerScript
	Quick
	Sql
	Svg
	Widgets
	Xml
	XmlPatterns
	Test
	Designer
	QuickControls2
	QuickTemplates2
	QuickWidgets
	)

include(${CMAKE_CURRENT_LIST_DIR}/qt_macro.cmake)

if(APPLE)
	append_unique(qt5Modules MacExtras DBus) # DBus нужен для qcocoa.
endif()
if(WIN32)
	append_unique(qt5Modules WinExtras)
endif()
if(LINUX)
	append_unique(qt5Modules X11Extras DBus)
endif()

if(WEB_ENGINE_REQUIRED)
	append_unique(qt5Modules WebEngine WebEngineCore WebEngineWidgets WebChannel)
endif()

function(ExpandQtDependencies ModulesList)
	set(result)
	foreach(module ${${ModulesList}})
		append(result ${module})
		if (module STREQUAL "Gui")
			append(result Core)
		endif()
		if (module STREQUAL "Widgets")
			append(result Gui Core)
		endif()
		if (module STREQUAL "Qml")
			append(result Network Core QmlModels QmlWorkerScript)
		endif()
		if (module STREQUAL "Quick")
			append(result Qml Gui Network Core QmlModels QmlWorkerScript)
		endif()
		if (APPLE AND (module STREQUAL "Widgets" OR module STREQUAL "Gui"))    # для работы Gui нужен DBus и PrintSupport на Apple.
			append(result DBus PrintSupport)
		endif()
	endforeach()
	list(REMOVE_DUPLICATES result)
	foreach(module ${result})
		if(NOT ${module} IN_LIST qt5Modules)
			list(REMOVE_ITEM result ${module})
		endif()
	endforeach()
	set(${ModulesList} ${result} PARENT_SCOPE)
endfunction()

function(CopyQtPlugins)
	if (NOT WIN32)
		return()
	endif()
	foreach(plugin ${QT_PLUGINS_FILES})
		set(plugin Qt5::${plugin}Plugin)
		if (NOT TARGET ${plugin})
			message(SEND_ERROR "Missing imported target for ${plugin}")
		endif()

		get_target_property(imploc_RELEASE ${plugin} IMPORTED_LOCATION_RELEASE)
		get_target_property(imploc_DEBUG   ${plugin} IMPORTED_LOCATION_DEBUG)

		#  имя директории с плагином.
		get_filename_component(pluginPath ${imploc_RELEASE} DIRECTORY)
		get_filename_component(pluginDir ${pluginPath} NAME)

		string(REPLACE ".dll" ".pdb" imploc_PDB "${imploc_DEBUG}")
		if (NOT EXISTS "${imploc_PDB}")
			message(WARNING "${imploc_PDB} is missing")
			set(imploc_PDB)
		endif()
		set(allFiles ${imploc_RELEASE} ${imploc_DEBUG} ${imploc_PDB})
		if (CMAKE_BUILD_TYPE STREQUAL "Release")
			set(allFiles ${imploc_RELEASE} )
		elseif(CMAKE_BUILD_TYPE STREQUAL "Debug")
			set(allFiles ${imploc_DEBUG} ${imploc_PDB})
		endif()
		file(COPY ${allFiles} DESTINATION ${BIN_DIR}/${pluginDir}   NO_SOURCE_PERMISSIONS)
	endforeach()
endfunction()

set( QT_PLUGINS_FILES "" CACHE INTERNAL "" FORCE) # список плагинов вроде QJpeg или QWindowsIntegration

if(LINUX)
	configure_file( ${SCRIPT_HELPERS_DIR}/qt.conf.nofixup.in ${BIN_DIR}/qt.conf @ONLY )
else()
	# Генерируем qt.conf в bin, откуда будем его копировать в инсталлятор/бандл
	# Этот конфиг используется для того, чтобы указать пути к директориям с зависимостями
	set(QT_CONF_PLUGINS_PATH Plugins) # на Win нет нужды указывать доп. директорию, т.к. текущая корневая тоже будет в списке поиска. Но может быть удобно для других платформ.
	set(QT_CONF_QML_PATH qml)
	if (APPLE)
		set(QT_CONF_PLUGINS_PATH PlugIns)
		set(QT_CONF_QML_PATH Resources/qml)
	endif()
#	configure_file( ${SCRIPT_HELPERS_DIR}/qt.conf.in ${BIN_DIR}/qt.conf @ONLY )
endif()

find_package(Qt5Core)
if(Qt5Core_VERSION VERSION_LESS 5.14.0)
	list(REMOVE_ITEM qt5Modules QmlModels)
	list(REMOVE_ITEM qt5Modules QmlWorkerScript)
endif()

foreach(qt5Module ${qt5Modules})
	find_package(Qt5${qt5Module})
	if(APPLE)
		set(FRAMEWORK_BUNDLE_SUFFIX_Qt${qt5Module} Versions/5/)
	endif()
endforeach()

append_unique(FRAMEWORKS_SEARCH_PATH ${QT_ROOT_PATH}/lib)

if (APPLE)
	foreach(qt5Module ${qt5Modules})
		if (qt5Module STREQUAL "WebEngine")
			message(STATUS "Add QtWebEngineProcess as imported target")
			add_executable(QtWebEngineProcess IMPORTED)
			set_property(TARGET QtWebEngineProcess PROPERTY IMPORTED_LOCATION ${QT_ROOT_PATH}/lib/QtWebEngineCore.framework/Versions/5/Helpers/QtWebEngineProcess.app/Contents/MacOS/QtWebEngineProcess)
			set(RUNTIME_FILE_QtWebEngineProcess_Debug QtWebEngineProcess)
			set(RUNTIME_FILE_QtWebEngineProcess_Release QtWebEngineProcess)

			# From https://codereview.qt-project.org/c/qt/qtwebengine/+/280965/4/src/process/Entitlements_mac.plist
			set(ENTITLEMENTS_QtWebEngineProcess "${SCRIPT_HELPERS_DIR}/MAC/QtWebEngineProcess.entitlements" CACHE STRING "" FORCE)
		endif()
	endforeach()
endif()

# подготовка workspace
if(WIN32)
	foreach(qt5Module ${qt5Modules})
		set(plugins
				PLUGINS_DEBUG
					${QT_ROOT_PATH}/bin/Qt5${qt5Module}d.dll
					${QT_ROOT_PATH}/bin/Qt5${qt5Module}d.pdb
				PLUGINS_RELEASE
					${QT_ROOT_PATH}/bin/Qt5${qt5Module}.dll
				)

		if (qt5Module STREQUAL "WebEngine")
			set(plugins ${plugins}
				PLUGINS_DEBUG
					${QT_ROOT_PATH}/bin/QtWebEngineProcessd.exe
				PLUGINS_RELEASE
					${QT_ROOT_PATH}/bin/QtWebEngineProcess.exe
				WORKSPACE_FILES
					${QT_ROOT_PATH}/resources
					${QT_ROOT_PATH}/translations/qtwebengine_locales
				)
		endif()

		AddThirdpartyModule(NAME qtdll::${qt5Module} ${plugins})
	endforeach()
	AddThirdpartyModule(NAME qtdll::OpenGLExtensions) # фейковый модуль.

	set(excludeMasks)
	if (CMAKE_BUILD_TYPE STREQUAL "Release") # если конфигурим ТОЛЬКО в релиз (make/ninja), то сэкономим место:
		set(excludeMasks PATTERN "*.pdb" EXCLUDE PATTERN "*d.dll" EXCLUDE) # Canvas3dd.dll мы тоже исключили, но он пока не нужен.
	endif()
	file(COPY ${QT_ROOT_PATH}/qml DESTINATION ${BIN_DIR} NO_SOURCE_PERMISSIONS ${excludeMasks})
endif()

if (LINUX)
	append(PREPARE_WORKSPACE_FILES ${QT_ROOT_PATH}/lib/libicu*.so*)
	set( PREPARE_WORKSPACE_FILES ${PREPARE_WORKSPACE_FILES} CACHE INTERNAL "" FORCE)
endif()

AddThirdpartyModule(NAME qt
	INCLUDE_DIRECTORIES
		${CMAKE_CURRENT_BINARY_DIR}
		[ WIN32 "${QT_ROOT_PATH}/include/QtZlib/" ]  # может понадобиться для quazip.
	PRIVATE_DEFINITIONS   [ WIN32  -DUNICODE -D_UNICODE ]
	)

SOURCE_GROUP( "Generated Files\\moc" REGULAR_EXPRESSION "moc_.*" )
SOURCE_GROUP( "Generated Files\\ui"  REGULAR_EXPRESSION "ui_.*" )
SOURCE_GROUP( "Generated Files\\qrc" REGULAR_EXPRESSION "qrc_.*" )
SOURCE_GROUP( "Resource Files\\qrc"  REGULAR_EXPRESSION ".*\\.qrc" )
SOURCE_GROUP( "Resource Files\\ts"   REGULAR_EXPRESSION ".*\\.ts" )
SOURCE_GROUP( "Resource Files\\qm"   REGULAR_EXPRESSION ".*\\.qm" )
SOURCE_GROUP( "Resource Files\\mopo"   REGULAR_EXPRESSION ".*\\.mo|.*\\.po")

configure_file(${BUILDSCRIPTS_HELPERS_DIR}/MocWrapper.cmake.in ${CMAKE_BINARY_DIR}/MocWrapper.cmake @ONLY)
