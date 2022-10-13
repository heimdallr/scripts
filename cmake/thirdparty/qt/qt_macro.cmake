include_guard(GLOBAL)

AddAuxiliaryTarget(GeneratedUiFiles)

# Вспомогательная функция для QT_WRAP_UI_CUSTOM - записывает в "глобальный" список все ui_ хедеры, которые были сгенерированы.
function(storeGeneratedUiHeaders)
	get_target_property(headers GeneratedUiFiles UI_HEADERS)
	if (NOT headers)
		set(headers)
	endif()
	append(headers ${ARGN})
	if (headers)
		set_target_properties(GeneratedUiFiles PROPERTIES UI_HEADERS "${headers}")
	endif()
endfunction()

# QT_WRAP_UI_CUSTOM(outfiles extraIncludes extraPostprocess inputfile1 inputfile2 ... )
# Функция предназначена для обертки Ui файлов.
# В отличии от оригинального QT5_WRAP_UI, кладёт сгенерированные ui_*.h файлы
# в отдельную папку, как у moc файлов, и автоматически дополняет extraIncludes необходимыми путями.
function(QT_WRAP_UI_CUSTOM outfiles extraIncludes extraPostprocess)
	if(WARN_DISABLE_DEPRECATED)
		set(_QT5_INTERNAL_SCOPE ON) # @todo Workaround
	endif()
	set(options)
	set(oneValueArgs)
	set(multiValueArgs OPTIONS)

	cmake_parse_arguments(_WRAP_UI "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	set(ui_files ${_WRAP_UI_UNPARSED_ARGUMENTS})
	set(ui_options ${_WRAP_UI_OPTIONS})
	set(includes)

	foreach(it ${ui_files})
		get_filename_component(outfile ${it} NAME_WE)
		get_filename_component(infile ${it} ABSOLUTE)

		QT5_MAKE_OUTPUT_FILE(${it} ui_ h outfile)
		# Дополнение директорий заголовочных файлов
		get_filename_component(incl_path ${outfile} PATH)

		set(postprocessArgs)
		foreach(cmakeScript ${extraPostprocess})
			append(postprocessArgs COMMAND ${CMAKE_COMMAND} ARGS -DINPUT=${outfile} -P ${cmakeScript})
		endforeach()

		append_unique( includes ${incl_path} )
		add_custom_command(OUTPUT ${outfile}
		  COMMAND ${Qt5Widgets_UIC_EXECUTABLE} ARGS ${ui_options} -o ${outfile} ${infile}
		  ${postprocessArgs}
		  MAIN_DEPENDENCY ${infile} VERBATIM)
		list(APPEND ${outfiles} ${outfile})
	endforeach()
	storeGeneratedUiHeaders(${${outfiles}})
	set(${outfiles} ${${outfiles}} PARENT_SCOPE)
	set(${extraIncludes} ${includes} PARENT_SCOPE)
endfunction()

# Функция удаляет из сборочной директории все файлы ui_*.h которые не были добавлены с помощью QT_WRAP_UI_CUSTOM.
#
# Использование - просто добавьте вызов CleanupObsoleteUiHeaders() в конце CMakeLists.txt.
function(CleanupObsoleteUiHeaders)
	get_target_property(headers GeneratedUiFiles UI_HEADERS)
	if (NOT headers)
		set(headers)
	endif()
	file(GLOB_RECURSE existingHeaders ${CMAKE_BINARY_DIR}/ui_*.h)
	foreach(exisitingFile ${existingHeaders})
		if (NOT (exisitingFile IN_LIST headers))
			message(WARNING "${exisitingFile} is probably obsolete, removing it.")
			file(REMOVE ${exisitingFile})
		endif()
	endforeach()
endfunction()

# Макрос взят из Qt5CoreMacros.cmake и дополнен параметром isBinary, позволяющим добавлять в проекты бинарную сборку rcc файлов,
# а не только формирование cxx из ресурсов и включение их в модуль.
# QT_ADD_RESOURCES_CUSTOM(TRUE dst path/to/file.qrc) - file.qrc будет добавлен в dst, и будет собран в ${BIN_DIR}/resources/themes/${theme}/file.rcc
# QT_ADD_RESOURCES_CUSTOM(FALSE dst path/to/file.qrc) - file.qrc будет добавлен в dst, и будет влинкован в модуль, зависящий от dst.
function(QT_ADD_RESOURCES_CUSTOM isBinary outfiles )
	if(WARN_DISABLE_DEPRECATED)
		set(_QT5_INTERNAL_SCOPE ON) # @todo Workaround
	endif()

	if( ${isBinary} )
		set(flag -binary)
		set(ext rcc)
		set(prefix ${BIN_DIR}/resources/themes/${theme}/)
	else()
		set(flag -name)
		set(ext cxx)
		set(prefix ${CMAKE_CURRENT_BINARY_DIR}/qrccpp/)
		file(MAKE_DIRECTORY ${prefix})
	endif()

	set(options)
	set(oneValueArgs)
	set(multiValueArgs OPTIONS)

	cmake_parse_arguments(_RCC "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

	set(rcc_files ${_RCC_UNPARSED_ARGUMENTS})
	set(rcc_options ${_RCC_OPTIONS})

	foreach(it ${rcc_files})
		get_filename_component(outfilename ${it} NAME_WE)
		get_filename_component(infile ${it} ABSOLUTE)
		get_filename_component(rc_path ${infile} PATH)
		set(outfile ${prefix}${outfilename}.${ext})
		if( ${isBinary} )
			set(outfilename)
		endif( ${isBinary} )

		set(_RC_DEPENDS)
		if(EXISTS "${infile}")
			#  parse file for dependencies
			#  all files are absolute paths or relative to the location of the qrc file
			file(READ "${infile}" _RC_FILE_CONTENTS)
			string(REGEX MATCHALL "<file[^<]+" _RC_FILES "${_RC_FILE_CONTENTS}")
			string(REGEX REPLACE "<file[^>]*>" "" _RC_FILES "${_RC_FILES}")
			set(_RC_DEPENDS)
			foreach(_RC_FILE ${_RC_FILES})
				set(_RC_DEPENDS ${_RC_DEPENDS} "${rc_path}/${_RC_FILE}")
			endforeach()
			# Since this cmake macro is doing the dependency scanning for these files,
			# let's make a configured file and add it as a dependency so cmake is run
			# again when dependencies need to be recomputed.
			qt5_make_output_file("${infile}" "" "qrc.depends" out_depends)
			configure_file("${infile}" "${out_depends}" COPYONLY)
		else()
			# The .qrc file does not exist (yet). Let's add a dependency and hope
			# that it will be generated later
			set(out_depends)
		endif()

		add_custom_command(OUTPUT ${outfile}
						   COMMAND ${Qt5Core_RCC_EXECUTABLE}
						   ARGS ${rcc_options} ${flag} ${outfilename} -o ${outfile} ${infile}
						   MAIN_DEPENDENCY ${infile}
						   DEPENDS ${_RC_DEPENDS} "${out_depends}" VERBATIM)
		list(APPEND ${outfiles} ${outfile})
	endforeach()
	set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()

function(QT5_WRAP_CPP_CUSTOM outfiles hasDesigner mocIncludes)
	if(WARN_DISABLE_DEPRECATED)
		set(_QT5_INTERNAL_SCOPE ON) # @todo Workaround
	endif()
	string(REPLACE ";" "," mocIncludes "${mocIncludes}")
	foreach(it ${ARGN})
		get_filename_component(it ${it} ABSOLUTE)
		QT5_MAKE_OUTPUT_FILE(${it} moc_ cpp outfile) #todo: подумать как ускорить этот вызов.
		add_custom_command(
			OUTPUT ${outfile}
			COMMAND ${CMAKE_COMMAND} -DINFILE=${it} -DOUTFILE=${outfile} -DHAS_DESIGNER=${hasDesigner} -DINCLUDES=${mocIncludes} -P ${CMAKE_BINARY_DIR}/MocWrapper.cmake
			DEPENDS ${it}
			VERBATIM)
		list(APPEND ${outfiles} ${outfile})
	endforeach()
	set(${outfiles} ${${outfiles}} PARENT_SCOPE)
endfunction()

# Функция вызывается в cmake файлах qt проектов, перед add_executable
# и add_library, вместо обычного preTarget.
# Ожидаются установленными переменные CURRENT_HEADERS, CURRENT_FORMS, CURRENT_RESOURCES.
# hasDesigner - есть ли модуль QtDesigner
# заполняются переменные outFilesName - сгенерированные файлы, outUiFilesName - ui_*.h хидеры, и extraIncludes - дополнительные инклюды для проекта
# в переменную mocFiles будут помещены MOC-файлы
function(preTargetQt hasDesigner mocIncludes uiPostprocess outFilesName outUiFilesName extraIncludes mocFiles)

		QT5_WRAP_CPP_CUSTOM(CURRENT_SOURCES_MOC "${hasDesigner}" "${mocIncludes}" ${CURRENT_HEADERS})

		QT_WRAP_UI_CUSTOM(CURRENT_SOURCES_UI extraUiIncludes "${uiPostprocess}" ${CURRENT_FORMS} )
		QT_ADD_RESOURCES_CUSTOM(FALSE CURRENT_SOURCES_RCC ${CURRENT_RESOURCES})

		if( APPLE )
			# Поочему то на винде с этими файлами студия не может прочитать сгенерированные Qt проекты: An item with the same key has already been added
			set( EXTRA_QT_FILES ${CURRENT_FORMS} ${CURRENT_RESOURCES} )
		endif()

		set(${extraIncludes} ${extraUiIncludes} PARENT_SCOPE)
		set(${mocFiles} ${CURRENT_SOURCES_MOC} PARENT_SCOPE)
		set(${outUiFilesName} ${CURRENT_SOURCES_UI} PARENT_SCOPE)
		set(${outFilesName} ${CURRENT_SOURCES_MOC} ${CURRENT_SOURCES_RCC} ${EXTRA_QT_FILES} PARENT_SCOPE)
endfunction()
