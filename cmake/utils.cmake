include_guard(GLOBAL)

include(CMakeParseArguments)

# Добавляет в список LIST_NAME элемент NEW_ELEMENT
# Пример:
# append(EXTRA_INCLUDE_DIRECTORIES dir1 [dir2 [dirN...]])
macro(append LIST_NAME)
	LIST( APPEND ${LIST_NAME} ${ARGN} )
endmacro()

# Добавляет в список LIST_NAME уникальные элементы
# Пример:
# append_unique(EXTRA_INCLUDE_DIRECTORIES dir1 [dir2 [dirN...]])
macro(append_unique LIST_NAME)
	LIST( APPEND ${LIST_NAME} ${ARGN} )
	LIST( REMOVE_DUPLICATES ${LIST_NAME} )
endmacro()

# Убирает повторящиеся элементы из списка без учета регистра
# Пример:
# правильно - remove_duplicates_insensitive( EXTRA_INCLUDE_DIRECTORIES )
function(remove_duplicates_insensitive LIST_NAME)
	set( lowercase_list )
	set( out_list)
	foreach (val ${${LIST_NAME}})
		string( TOLOWER "${val}" valLower )
		list(FIND lowercase_list "${valLower}" lowerIndex)
		if (NOT (${lowerIndex} EQUAL -1 ))
			continue()
		endif()
		append(lowercase_list "${valLower}")
		append(out_list "${val}")
	endforeach()
	set(${LIST_NAME} ${out_list} PARENT_SCOPE)
endfunction()

# Проходит по списку, удаляя для каждого элемента часть строки.
# Вызов: list_each_remove(LIST_NAME "/some/path/")
function(list_each_remove LIST_NAME SUBSTRING)
	set(_TMP_LIST)
	foreach (val ${${LIST_NAME}})
		string (REPLACE "${SUBSTRING}" "" val "${val}")
		append(_TMP_LIST "${val}")
	endforeach()
	set (${LIST_NAME} ${_TMP_LIST} PARENT_SCOPE)
endfunction()

# Проверяет, есть ли элемент в списке, и выставляет VAR_NAME в true или false.
# Вызов: list_exists_item(HAYSTACK_VAR "needle" IS_EXISTS_VAR)
function(list_exists_item HAYSTACK ITEM IS_EXISTS_VAR)
	set(${IS_EXISTS_VAR} false PARENT_SCOPE)
	list(FIND ${HAYSTACK} "${ITEM}" _index)
	if (NOT (_index STREQUAL -1))
		set(${IS_EXISTS_VAR} true PARENT_SCOPE)
	endif()
endfunction()

# Обединет элементы списка LIST в строку, разделяя их указанным разделителем
# Вызов: join(INPUT_LIST_NAME ":" OUPUT_LIST_NAME)
function(join LIST SEPARATOR OUTPUT)
	string (REGEX REPLACE "([^\\]|^);" "\\1${SEPARATOR}" _TMP_STR "${${LIST}}")
	string (REGEX REPLACE "[\\](.)" "\\1" _TMP_STR "${_TMP_STR}") #fixes escaping
	set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

macro(SeparateComma __tmp)
	# На всякие случай, если список в переменной задан с кавычками
	string(REPLACE "\"" "" ${__tmp} ${${__tmp}})
	string(REPLACE "," ";" ${__tmp} ${${__tmp}})
endmacro()

macro(ReplaceSemicolonToComma __tmp)
	string(REPLACE ";" "," ${__tmp} "${${__tmp}}")
endmacro()

macro(ReplaceDirectionRightToComma __tmp)
	string(REPLACE "->" "," ${__tmp} "${${__tmp}}")
	string(REPLACE ">" "," ${__tmp} "${${__tmp}}")
endmacro()

macro(DeleteDublicateComma __tmp)
	while(NOT isEqual)
		string(COMPARE EQUAL "${__tmp2}" "${${__tmp}}" isEqual)
		string(REPLACE ",," "," __tmp2 "${${__tmp}}")
		set(${__tmp} ${__tmp2})
	endwhile()
endmacro()

# Получает список out из переменной окружения env_list
# Если переменная не определена изаданы значения по умолчанию, то они будут в нее подставлены
# Пример:
# get_env_list(themes INCLUDE_THEMES Dark Light)
function(get_env_list out env_list)
	set(tmp $ENV{${env_list}})
	if(DEFINED tmp)
		# Из Jenkins списки приходят с запятой в качестве разделителя
		SeparateComma(tmp)
		set(${out} ${tmp} PARENT_SCOPE)
	elseif(ARGN)
		set(${out} ${ARGN} PARENT_SCOPE)
	endif(DEFINED tmp)
endfunction()

# Проверяет существование файла или директории. При ошибке выводит сообщение со статусом SEND_ERROR
# Пример:
# check_if_exists("path/to/file" "custom error message")
# или
# check_if_exists("path/to/file")
function(check_if_exists filepath)
	if( NOT EXISTS ${filepath} )
		if( NOT ARGN )
			set(ARGN "File ${filepath} does not exists")
		endif( NOT ARGN )

		message( SEND_ERROR ${ARGN} )
	endif( NOT EXISTS ${filepath} )
endfunction()

# Создаёт пары key:variable из списка переданных аргументов
# CreatePairsKeyValue([key1 value1] [key2 value2] ...)
# Список ключей можно прочитать из переменной __CreatePairsKeyValue_keys
# Вызов функции CreatePairsKeyValue(key1 value1 key2 value2)
# Аналогичен записи:
# set(key1 value1)
# set(key2 value2)
macro(CreatePairsKeyValue)
	set(__args ${ARGN})
	list(LENGTH __args __len)
	math(EXPR __mod2 "${__len} % 2" )
	if(NOT (__mod2 EQUAL 0))
		message(FATAL_ERROR "Invalid count arguments: ${__args}")
	endif(NOT (__mod2 EQUAL 0))

	set(__CreatePairsKeyValue_keys)
	set(__pos 0)
	while(__pos LESS __len)
		list(GET __args ${__pos} __key)
		math(EXPR __pos "${__pos}+1")
		list(GET __args ${__pos} __value)
		math(EXPR __pos "${__pos}+1")
		set(${__key} ${__value})
		set(__CreatePairsKeyValue_keys ${__CreatePairsKeyValue_keys} ${__key})
	endwhile(__pos LESS __len)
endmacro()

# Проверяет объявлены ли переменные из списка.
# Если хотя бы одна переменная не обхявлена вызывается FATAL_ERROR
# CheckRequiredVariables([var1] [var2] ...)
function(CheckRequiredVariables)
	foreach(var ${ARGN})
		if(NOT DEFINED ${var})
			message(FATAL_ERROR "Not defined required variable '${var}'")
		endif(NOT DEFINED ${var})
	endforeach(var ${ARGN})
endfunction()

# Проверяет являются ли переменные из списка пустыми
# В случае ошибки пишется FATAL_ERROR
# CheckNonEmptyVariables([var1] [var2] ...)
function(CheckNonEmptyVariables)
	foreach(var ${ARGN})
		if("${${var}}" STREQUAL "" OR "${${var}}" STREQUAL " ")
			message(FATAL_ERROR "Variable '${var}' must be non empty")
		endif("${${var}}" STREQUAL "" OR "${${var}}" STREQUAL " ")
	endforeach(var ${ARGN})
endfunction()

# Проверяет являются ли переменная пустой
# В случае ошибки пишется FATAL_ERROR
# CheckNonEmptyVariable(var "appstore requirement")
function(CheckNonEmptyVariable var failMessage)
	if("${${var}}" STREQUAL "" OR "${${var}}" STREQUAL " ")
		message(FATAL_ERROR "Variable '${var}' must be non empty: ${failMessage}")
	endif("${${var}}" STREQUAL "" OR "${${var}}" STREQUAL " ")
endfunction()

# Подключает модули
# IncludeModules(
#	root_dir					# корневой каталог, относительно которого подключаются модули
#	[module1] [module2] ...		# список модулей (путь к подключаемым *.cmake файлам)
#	)
function(IncludeModules __root_dir)
	function(InternalFunc path)
		include(${path})
	endfunction(InternalFunc path)
	foreach(module_path ${ARGN})
			InternalFunc(${__root_dir}/${module_path})
	endforeach(module_path)
endfunction()

# Копирует файл <source> в файл <destination>.
# При необходимости создаёт путь до <destination>, если его не существует
function(copyFile source destination)
	CheckRequiredVariables(source destination)
	check_if_exists(${source})
	configure_file(${source} ${destination} COPYONLY)
	check_if_exists(${destination})
endfunction()

# Копирует директорию <source> в <destination>/.. и переименовывает её в <destination>
# При необходимости создаёт путь до <destination>
# Пример: copyDirectory(dir1 /path/to/dir2) - создаст путь /path/to, скопирует туда dir1 и переименует её в dir2
function(copyDirectory source destination)
	CheckRequiredVariables(source destination)
	check_if_exists(${source})

	if ( NOT EXISTS ${destination} )
		file(MAKE_DIRECTORY ${destination})
	endif()

	file(COPY ${source}/ DESTINATION ${destination})
	check_if_exists(${destination})
endfunction()

# Копирует/заменяет в bin конфигурационные файлы находящиеся в configDir и указаных поддиректориях
# PrepareConfigFiles(
#	<configDir>			# Путь к файлам конфигурации
#	[dir1 [dir2...]]	# Имена поддиректорий с дополнительными файлами
#	)
function(PrepareConfigFiles configDir)
	message(STATUS "Preparing ${BIN_DIR}..." )
	foreach(dir . ${ARGN})
		file(GLOB srcs ${configDir}/${dir}/*.*)
		foreach(src ${srcs})
			string(REGEX REPLACE "^${configDir}/" "" src ${src})
			string(REGEX REPLACE "^${dir}/" "" src ${src})
			file(REMOVE ${BIN_DIR}/${src})
		endforeach(src ${srcs})
		file(COPY ${srcs} DESTINATION ${BIN_DIR})
	endforeach(dir . ${ARGN})
endfunction()

# Раскрывает в переданном списке ListName условия, заключенные в квадратные скобки, например:
#[[
set(test
	foo
	# Синтаксис с односложным условием и возможным отрицанием
	[ WIN32 win-only0 win-only1 ]
	[ APPLE apple-only0 ]
	[ NOT APPLE not-apple0 ]

	# Синтаксис тернарного оператора [ condition ? then : else ]
	[ WIN32 ? win-only2 ] # if-then
	[ WIN32 ? win-only4 : not-win0 ] # if-then-else

	# WRONG
	[ true : ? beee ] -> FATAL_ERROR
	[ true : ? beee : fooo ] -> FATAL_ERROR

	# Другие варианты использования см. в ExpandListConditionsUnitTest
	)
ExpandListConditions(test)

Вложенные условия не поддерживаются.

Внимание: важно след. символы '[]?:'  отделять пробелами/другим whitespace.
#]]
function(ExpandListConditions ListName)
	set(resultElements)
	foreach (element ${${ListName}})
		if (NOT ("${element}" MATCHES "\\[;.*"))
			list(APPEND resultElements ${element})
			continue()
		endif()
		if ("${element}" STREQUAL "[;]")
			message(SEND_ERROR "Empty square brackets conditions not allowed!")
			continue()
		endif()
		# remove opening and closing brackets
		string(REPLACE "[;" "" element "${element}")
		string(REPLACE ";]" "" element "${element}")

		string(FIND "${element}" ";?" thenIndex)
		if (NOT thenIndex EQUAL -1) # Тернарный синтаксис

			string(FIND "${element}" ";:" elseIndex)
			string(LENGTH "${element}" len)
			string(SUBSTRING "${element}" 0 ${thenIndex} condition)

			set(elseValue)
			if (NOT elseIndex EQUAL -1)
				if (elseIndex LESS thenIndex)
					message(FATAL_ERROR "Wrong [ condition ? then : else ] syntax: expects ':' after '?':\n${element}")
				endif()
				math(EXPR elseBeginIndex "${elseIndex} + 2" )
				math(EXPR elseLen "${len} - ${elseBeginIndex}" )
				string(SUBSTRING "${element}" ${elseBeginIndex} ${elseLen} elseValue)
			else()
				set(elseIndex ${len})
			endif()

			if (NOT elseIndex EQUAL thenIndex)
				math(EXPR thenBeginIndex "${thenIndex} + 2" )
				math(EXPR thenLen "${elseIndex} - ${thenBeginIndex}" )
				string(SUBSTRING "${element}" ${thenBeginIndex} ${thenLen} thenValue)

				if (${condition})
					list(APPEND resultElements ${thenValue})
				else()
					list(APPEND resultElements ${elseValue})
				endif()
			endif()

		else () # Односложный синтаксис
			list(LENGTH element len)
			list(GET element 0 condition)
			list(REMOVE_AT element 0)
			set(conditionResult false)
			set(inverse false)
			if (condition STREQUAL "NOT")
				set(inverse true)
				list(GET element 0 condition)
				list(REMOVE_AT element 0)
			endif()
			if (${condition})
				set(conditionResult true)
			endif()
			# conditionResult = !conditionResult;
			if (inverse)
				if (conditionResult)
					set(conditionResult false)
				else()
					set(conditionResult true)
				endif()
			endif()
			if (conditionResult AND element)
				list(APPEND resultElements ${element})
			endif()
		endif()
	endforeach()
	set(${ListName} ${resultElements} PARENT_SCOPE)
endfunction()

macro(requireStringValue VARIABLE STRING)
	if (NOT "${${VARIABLE}}" STREQUAL "${STRING}")
		message(SEND_ERROR "Expected \'${STRING}\' string instead of \'${${VARIABLE}}\'")
	endif()
endmacro()

function(ExpandListConditionsUnitTest)
	set(input baa [ true then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ NOT true then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ false then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ NOT false then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ ? ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ ? : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ true ? ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ false ? ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ true ? : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ false ? : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ ? true : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ ? : false ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ ? true : false ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ true ? then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ NOT true ? then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ false ? then-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ true ? then-value : ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ NOT true ? then-value : ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ true ? then-value : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ false ? then-value : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;else-value")

	set(input baa [ true OR false ? then-value : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;then-value")

	set(input baa [ false OR false ? then-value : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;else-value")

	set(input baa [ true ? : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa")

	set(input baa [ false ? : else-value ])
	ExpandListConditions(input)
	requireStringValue(input "baa;else-value")

	set(input baa [ true ? "some text with ? and :" : "else" ])
	ExpandListConditions(input)
	requireStringValue(input "baa;some text with ? and :")

	set(input baa [ true  ?  ?   : : ?  ])
	#                     | then | else |
	ExpandListConditions(input)
	requireStringValue(input "baa;?")

	set(input baa [ false ?  ?   : : ?  ])
	#                     | then | else |
	ExpandListConditions(input)
	requireStringValue(input "baa;:;?")

endfunction()

# Получает свойство цели, очищая его, если оно не найдено.
function(GetTargetPropertyEmptyOnNonFound VARIABLE TARGET_NAME PROPERTY_NAME)
	get_target_property(value ${TARGET_NAME} ${PROPERTY_NAME})
	if (NOT value)
		set(value) # очищаем NOT-FOUND
	endif()
	set(${VARIABLE} ${value} PARENT_SCOPE)
endfunction()

# Получает свойство цели, очищая его, если оно не найдено.
function(ExtractTargetPropertyToList LIST_VARIABLE TARGET_NAME PROPERTY_NAME)
	GetTargetPropertyEmptyOnNonFound(tmp ${TARGET_NAME} ${PROPERTY_NAME})
	if (tmp)
		set(result ${${LIST_VARIABLE}})
		append_unique(result ${tmp})
		set(${LIST_VARIABLE} ${result} PARENT_SCOPE)
	endif()
endfunction()

# Аналог функции cmake_parse_arguments, только автоматически применяет раскрытие условий и проверку переменных.
macro(ParseArgumentsWithConditions argName options oneValRequired oneValOptional multiVal)
	set(__allArgs ${ARGN})
	ExpandListConditions(__allArgs)
	cmake_parse_arguments(${argName} "${options}" "${oneValRequired};${oneValOptional}" "${multiVal}" ${__allArgs})
	if(${argName}_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "invalid arguments: ${__allArgs}, unparsed:${${argName}_UNPARSED_ARGUMENTS}")
	endif()
	foreach(__varName ${oneValRequired})
		CheckRequiredVariables(${argName}_${__varName})
	endforeach()
endmacro()

# Вспомогательная цель.
# В отличие от add_custom_target не светится в целях сборки, но позволяет задавать и читать атрибуты.
# Замена глобальным переменным, т.к. не пишется в кеш-файл между сборками.
function(AddAuxiliaryTarget name)
	add_library(${name} STATIC IMPORTED GLOBAL)
endfunction()

function(LinkSdkLibraryForConfig)
	set(__options
		APPEND_LIBPATH		# добавляет путь к корневой директории библиотек в EXTRA_LINK_DIRECTORIES
		DEBUG_SEPARATED
	)
	set(__one_val_required
		PACKAGE_NAME        # идентификатор пакета
		CONFIG              # RELEASE | DEBUG
		PKG_ROOT            # абсолютный путь к корню пакета, содержащему "lib" директорию
		TARGET_NAME         # имя интерфейсной цели
		)
	set(__one_val_optional
		SUFFIX
		)
	set(__multi_val
		LIBS				# список имен библиотек, которые будут искаться. Имена передаются в find_library.
		DLLS				# список имен dll, для копирования в workspace. pdb-файлы будут найдены исходя из этого списка.
	)
	ParseArgumentsWithConditions(ARG "${__options}" "${__one_val_required}" "${__one_val_optional}" "${__multi_val}" ${ARGN})
	
	set(config ${ARG_CONFIG})
	set(libpath "${ARG_PKG_ROOT}/lib")
	if (NOT EXISTS "${libpath}")
		message(FATAL_ERROR "failed to locate extracted path for: ${libpath}")
		return()
	endif()

	if (ARG_DEBUG_SEPARATED)
		if (config STREQUAL "RELEASE")
			set(libpath ${libpath}/Release)
		else()
			set(libpath ${libpath}/Debug)
		endif()
	endif()
	set(suffix ${ARG_SUFFIX})
	set(package ${ARG_PACKAGE_NAME})
	set(libs)

	foreach (lib ${ARG_LIBS})
		append(libs ${lib}${suffix})
	endforeach()
	set(searchFlags NO_DEFAULT_PATH NO_CMAKE_ENVIRONMENT_PATH NO_CMAKE_PATH NO_SYSTEM_ENVIRONMENT_PATH NO_CMAKE_SYSTEM_PATH NO_CMAKE_FIND_ROOT_PATH)

	# небольшое примечание: функция find_library всегда кеширует результат поиска, даже если изменились его аргументы (кроме имени).
	# таким образом, если не меняется версия библиотеки, и ключ "__LIB_${package}_${lib}_${config}" дает то же самое значение,
	# изменение компоновки пакета с динамической на статическую, например, не приведет автоматически к новому имени библиотеки без сброса кеша CMake.
	
	GetTargetPropertyEmptyOnNonFound(EXTRA_LINK_LIBRARIES_${config}     ${ARG_TARGET_NAME} EXTRA_LINK_LIBRARIES_${config})
	GetTargetPropertyEmptyOnNonFound(EXTRA_PLUGINS_${config}            ${ARG_TARGET_NAME} EXTRA_PLUGINS_${config})
	set(linkLibraries)
	foreach (lib ${libs})
		set(libKey SDK_LIB_${package}_${lib}_${config})
		find_library(${libKey} ${lib} PATHS ${libpath} ${searchFlags})
		if (NOT ${libKey}) # -NOT-FOUND тоже считается за false.
			message(SEND_ERROR "${libKey} is ${${libKey}}")
		endif()
		append(linkLibraries "${${libKey}}")
		mark_as_advanced(${libKey})
	endforeach()

	# здесь подразумевается, что pdb файлы не могут быть в сборке статичной библиотеки, что формально неверно.
	if (WIN32)
		foreach (dll ${ARG_DLLS})
			append(EXTRA_PLUGINS_${config} "${libpath}/${dll}${suffix}.dll")
			set (pdb "${libpath}/${dll}${suffix}.pdb")
			if (EXISTS ${pdb})
				append(EXTRA_PLUGINS_${config} ${pdb})
			endif()
		endforeach()
	else()
		foreach (lib ${ARG_LIBS})
			append( EXTRA_PLUGINS_${config} "${libpath}/${lib}${suffix}.so")
		endforeach()
	endif()

	# Если библиотека состоит из динамических модулей, например, dylib или so, мы их должны включать в инсталлятор при линковке модуля.
	# для этого файлы помещаются в секцию PLUGINS так же.
	# под WIN - dll помещаются в секцию PLUGINS, а библиотеки импорта (lib) - в EXTRA_LINK_LIBRARIES (их только компонуем, никуда не устанавливаем)

	append(EXTRA_LINK_LIBRARIES_${config} ${linkLibraries})

	set_target_properties(${ARG_TARGET_NAME} PROPERTIES
		EXTRA_LINK_LIBRARIES_${config}      "${EXTRA_LINK_LIBRARIES_${config}}"
		EXTRA_PLUGINS_${config}             "${EXTRA_PLUGINS_${config}}"
		)

	# по умолчанию мы всегда стремимся линковать файл библиотеки напрямую (так быстрее). Но для платформенных SDK, такой путь порой просто не работает -
	# приходится передавать директорию для компоновки. Нужно стараться свести к минимуму LINK_DIRECTORIES.
	if (ARG_APPEND_LIBPATH)
		set_target_properties(${ARG_TARGET_NAME} PROPERTIES EXTRA_LINK_DIRECTORIES "${libpath}")
	endif()
endfunction()

#подключает в качестве зависимости библиотеку из SDK, заполняя переменные
# EXTRA_LINK_LIBRARIES*, EXTRA_WORKSPACE_FILES, EXTRA_LINK_DIRECTORIES
# пример использования:
# set(__libs SomeLibName)
# set(_pkg_full libNameWithAbiAndVersion-1.0.0-win-x86-lib) # полное имя пакета для библиотеки.
# LinkSdkLibrary(${_pkg_full} LIBS ${__libs} DLLS ${__libs} APPEND_LIBPATH)
#
function(LinkSdkLibrary package)
	set(__options
		APPEND_LIBPATH		# добавляет путь к корневой директории библиотек в EXTRA_LINK_DIRECTORIES
		HAS_DEBUG
		DEBUG_SEPARATED
		ROOTS_SEPARATED     # отдельные корни для ROOT_DEBUG/ROOT_RELEASE
	)
	set(__one_val
		TARGET_NAME         # имя интерфейсной цели
		DEBUG_SUFFIX
		)
	set(__multi_val
		LIBS				# список имен библиотек, которые будут искаться. Имена передаются в find_library.
		DLLS				# список имен dll, для копирования в workspace. pdb-файлы будут найдены исходя из этого списка.
	)
	set(ARGN_EXPANDED ${ARGN})
	ExpandListConditions(ARGN_EXPANDED)

	cmake_parse_arguments(ARG "${__options}" "${__one_val}" "${__multi_val}" ${ARGN_EXPANDED})
	if (NOT ${package}_ROOT)
		message(FATAL_ERROR "${package}: Could not find suitable package - ${package}_ROOT=${${package}_ROOT}")
		return()
	endif()

	foreach (config RELEASE DEBUG)
		if (CMAKE_BUILD_TYPE)
			if (CMAKE_BUILD_TYPE STREQUAL "Debug")
				if (config STREQUAL "RELEASE")
					continue()
				endif()
			else() # Release, RelWithDeb, ...
				if (config STREQUAL "DEBUG")
					continue()
				endif()
			endif()
		endif()
		set(args)
		if (ARG_APPEND_LIBPATH)
			append(args APPEND_LIBPATH)
		endif()
		if (ARG_DEBUG_SEPARATED)
			append(args DEBUG_SEPARATED)
		endif()
		append(args
			PACKAGE_NAME  ${package}
			CONFIG        ${config}
			)
		if (ARG_ROOTS_SEPARATED)
			append(args PKG_ROOT  ${${package}_ROOT_${config}})
		else()
			append(args PKG_ROOT  ${${package}_ROOT})
		endif()
		append(args
			TARGET_NAME   ${ARG_TARGET_NAME}
			)
		if (ARG_DEBUG_SUFFIX AND config STREQUAL "DEBUG")
			append(args SUFFIX ${ARG_DEBUG_SUFFIX})
		endif()
		append(args
			LIBS ${ARG_LIBS}
			DLLS ${ARG_DLLS}
			)
		LinkSdkLibraryForConfig(${args})
	endforeach()
endfunction()
