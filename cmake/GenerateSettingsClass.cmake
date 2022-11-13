include_guard(GLOBAL)

function(GenerateSettingsClass CLASS_NAME SETTINGS_MAP)
	GetMapKeys(${SETTINGS_MAP} keys)

	set(content "#pragma once\n\n")
	list(APPEND content "#include <QObject>\n")
	list(APPEND content "#include <QVariant>\n")
	list(APPEND content "#include \"fnd/memory.h\"\n")
	list(APPEND content "#include \"util/Settings.h\"\n\n")

	list(APPEND content "namespace HomeCompa {\n\n")
	list(APPEND content "class ${CLASS_NAME} : public QObject {\n")
	list(APPEND content "\tQ_OBJECT\n\n")
	foreach(name ${keys})
		list(APPEND content "\tQ_PROPERTY(QVariant ${name} READ ${name} WRITE set_${name} NOTIFY ${name}Changed)\n")
	endforeach()
	list(APPEND content "\nsignals:\n")
	foreach(name ${keys})
		list(APPEND content "\tvoid ${name}Changed() const\;\n")
	endforeach()
	list(APPEND content "\nprivate:\n")
	GrabMapVariables(${SETTINGS_MAP} ${keys})
	foreach(name ${keys})
		list(APPEND content "\tvoid set_${name}(const QVariant & value) { m_settings->Set(\"${name}\", value)\; emit ${name}Changed()\; }\n")
	endforeach()
	list(APPEND content "\npublic:\n")
	list(APPEND content "\t${CLASS_NAME}(std::unique_ptr<Settings> settings) : m_settings(std::move(settings)) {}\n")
	list(APPEND content "\npublic:\n")
	foreach(name ${keys})
		list(APPEND content "\tQVariant ${name}() const { return m_settings->Get(\"${name}\", ${${name}})\; }\n")
	endforeach()
	list(APPEND content "\n\tQ_INVOKABLE void Reset()\n\t{\n")
	foreach(name ${keys})
		list(APPEND content "\t\tset_${name}(${${name}})\;\n")
	endforeach()
	list(APPEND content "\t}\n")
	list(APPEND content "\nprivate:\n")
	list(APPEND content "\tPropagateConstPtr<Settings> m_settings\;\n")
	list(APPEND content "}\;\n\n")
	list(APPEND content "}\n")

	set(headerFileQt "${CMAKE_CURRENT_BINARY_DIR}/Settings/${CLASS_NAME}.h")
	set(headerFileMoc "${CMAKE_CURRENT_BINARY_DIR}/Settings/moc_${CLASS_NAME}.cpp")

	file(WRITE ${headerFileQt} ${content})
	execute_process(COMMAND ${CMAKE_COMMAND} -DINFILE=${headerFileQt} -DOUTFILE=${headerFileMoc} -P ${CMAKE_BINARY_DIR}/MocWrapper.cmake  COMMAND_ERROR_IS_FATAL ANY)

	set(keyConstants "#pragma once\n\n")
	list(APPEND keyConstants "namespace HomeCompa::Constant::${CLASS_NAME}_ns {\n\n")
	foreach(name ${keys})
		list(APPEND keyConstants "constexpr auto ${name} = \"${name}\"\;\n")
	endforeach()
	list(APPEND keyConstants "\n}\n")
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/Settings/${CLASS_NAME}_keys.h" ${keyConstants})

endfunction()
