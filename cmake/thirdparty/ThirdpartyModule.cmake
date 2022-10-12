# Функция добавляет подключаемый модуль, который можно использовать в секции MODULES в AddTarget.
# Используется в основном для thirdparty-библиотек
function(AddThirdpartyModule)
	#! - обязательный параметр
	set(__options
		)
	set(__one_val
		NAME                      #! имя модуля.
		)
	set(__multi_val
		INCLUDE_DIRECTORIES       # include компилятора
		LINK_LIBRARIES            # дополнительные библиотеки на компоновку в дебаг и релиз
		LINK_LIBRARIES_DEBUG      # дополнительные библиотеки на компоновку в дебаг
		LINK_LIBRARIES_RELEASE    # дополнительные библиотеки на компоновку в релиз
		LINK_DIRECTORIES          # пути для компоновки. Желательно не использовать, кроме как для системных SDK.
		LINK_FLAGS                # дополнительные флаги компоновки
		PRIVATE_DEFINITIONS       # директивы препроцессора. -D добавлять не нужно.
		COMPILE_FLAGS             # дополнительные флаги сборки
		WORKSPACE_FILES           # файлы, которые будут помещены в workspace, но в цель фиксапа они не попадат (и в инсталлятор)
		PLUGINS                   # плагины, которые будут помещены в workspace и добавлены в инсталлятор. Отличие от просто файлов - они фиксапятся как библиотеки.
		PLUGINS_DEBUG             # плагины только для Debug. вручную передавать не нужно, будут заполнены LinkSdkLibrary.
		PLUGINS_RELEASE           # плагины только для Release. вручную передавать не нужно, будут заполнены LinkSdkLibrary.
		MACOS_FRAMEWORKS          # список подкладываемых в бандл фреймворков
		PKG_CONFIG                # имена модулей в pkg-config
		DEPS                      # зависимые модули, добавленные ранее через AddThirdpartyModule. Для текущего модуля все параметры будут сложены вместе с параметрами зависимых модулей.
	)
	set(args ${ARGN})
	ExpandListConditions(args)
	cmake_parse_arguments(ARG "${__options}" "${__one_val}" "${__multi_val}" ${args})
	
	if (ARG_PKG_CONFIG)
		include(FindPkgConfig)
		foreach (pkg ${ARG_PKG_CONFIG})
			pkg_check_modules(pkgc_${pkg} ${pkg} REQUIRED)
			append(ARG_INCLUDE_DIRECTORIES ${pkgc_${pkg}_INCLUDE_DIRS})
			# Если библиотека стоит по не стандартному пути, то для нее будет задан <XPREFIX>_LIBRARY_DIRS.
			# Для таких библиотек соберем абсолютный путь, чтобы избежать проблем при линковке и запуске.
			if(pkgc_${pkg}_LIBRARY_DIRS AND pkgc_${pkg}_LIBRARIES)
				foreach(lib ${pkgc_${pkg}_LIBRARIES})
					set(libPath)
					foreach(dir ${pkgc_${pkg}_LIBRARY_DIRS})
						if(EXISTS "${dir}/lib${lib}.so" AND NOT libPath)
							set(libPath "${dir}/lib${lib}.so")
						endif()
					endforeach()
					if(libPath)
						append(ARG_LINK_LIBRARIES ${libPath})
					else()
						append(ARG_LINK_LIBRARIES -l${lib})
					endif()
				endforeach()
			else()
				append(ARG_LINK_LIBRARIES ${pkgc_${pkg}_LDFLAGS})
			endif()
		endforeach()
	endif()

	# что это за магия? некоторые Find* скрипты выставляют LINK_LIBRARIES на такой список:
	# optimized;boost_thread.dll;debug;boost_thread-gd.dll
	# если такое передать в функцию target_link_libraries, cmake это все разруливает, но мы хотим извлечь отдельные файлы.
	foreach (lib ${ARG_LINK_LIBRARIES})
		if (lib STREQUAL "optimized")
			set(optimizedNext true)
		elseif(lib STREQUAL "debug")
			set(debugNext true)
		else()
			if(optimizedNext)
				set(optimizedNext)
				append(ARG_LINK_LIBRARIES_RELEASE ${lib})
			elseif(debugNext)
				set(debugNext)
				append(ARG_LINK_LIBRARIES_DEBUG ${lib})
			else()
				append(ARG_LINK_LIBRARIES_RELEASE ${lib})
				append(ARG_LINK_LIBRARIES_DEBUG ${lib})
			endif()
		endif()
	endforeach()

	foreach (dep ${ARG_DEPS})
		foreach (prop
				LINK_LIBRARIES_DEBUG
				LINK_LIBRARIES_RELEASE
				LINK_FLAGS
				INCLUDE_DIRECTORIES
				LINK_DIRECTORIES
				PRIVATE_DEFINITIONS
				COMPILE_FLAGS
				WORKSPACE_FILES
				PLUGINS
				PLUGINS_DEBUG
				PLUGINS_RELEASE
				MACOS_FRAMEWORKS
				)
				ExtractTargetPropertyToList(ARG_${prop} ${dep} EXTRA_${prop})
		endforeach()
	endforeach()

	AddAuxiliaryTarget(${ARG_NAME})

	set_target_properties(${ARG_NAME} PROPERTIES
		EXTRA_INCLUDE_DIRECTORIES         "${ARG_INCLUDE_DIRECTORIES}"
		EXTRA_LINK_LIBRARIES_DEBUG        "${ARG_LINK_LIBRARIES_DEBUG}"
		EXTRA_LINK_LIBRARIES_RELEASE      "${ARG_LINK_LIBRARIES_RELEASE}"
		EXTRA_LINK_FLAGS                  "${ARG_LINK_FLAGS}"
		EXTRA_LINK_DIRECTORIES            "${ARG_LINK_DIRECTORIES}"
		EXTRA_PRIVATE_DEFINITIONS         "${ARG_PRIVATE_DEFINITIONS}"
		EXTRA_COMPILE_FLAGS               "${ARG_COMPILE_FLAGS}"
		EXTRA_WORKSPACE_FILES             "${ARG_WORKSPACE_FILES}"
		EXTRA_PLUGINS                     "${ARG_PLUGINS}"
		EXTRA_PLUGINS_DEBUG               "${ARG_PLUGINS_DEBUG}"
		EXTRA_PLUGINS_RELEASE             "${ARG_PLUGINS_RELEASE}"
		EXTRA_MACOS_FRAMEWORKS            "${ARG_MACOS_FRAMEWORKS}"
		)

endfunction()
