include_guard(GLOBAL)

function(GenerateTranslations)
#	set(options )
	set(oneValueArgs NAME PATH)
	set(multiValueArgs FILES)
	cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	if (NOT ARG_FILES)
		return()
	endif()
	
	set(ts)
	add_custom_command(TARGET ${ARG_NAME}
	    PRE_BUILD
	    COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_BINARY_DIR}/bin/locales
	)
	foreach(file ${ARG_FILES})
		list(APPEND ts "${file}\n")
		get_filename_component( locale ${file} NAME_WE )
		add_custom_command(TARGET ${ARG_NAME}
		    PRE_BUILD
		    COMMAND ${QT_LRELEASE_TOOL} ${file} -qm ${CMAKE_BINARY_DIR}/bin/locales/${ARG_NAME}_${locale}.qm
		)
	endforeach()

	set(tslist "${CMAKE_BINARY_DIR}/resources/${ARG_NAME}_locales.tslist")
	file(WRITE ${tslist} ${ts})

	execute_process(COMMAND ${QT_LUPDATE_TOOL} -no-ui-lines "${ARG_PATH}" -ts "@${tslist}")
endfunction()
