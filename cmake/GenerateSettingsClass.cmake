include_guard(GLOBAL)

function(GenerateSettingsClass CLASS_NAME SETTINGS_MAP)
	GetMapKeys(${SETTINGS_MAP} keys)

	set(content "#pragma once\n\n")
	list(APPEND content "#include <QObject>\n\n")
	list(APPEND content "#include \"fnd/memory.h\"\n")
	list(APPEND content "#include \"fnd/FindPair.h\"\n")
	list(APPEND content "#include \"util/Settings.h\"\n")
	list(APPEND content "#include \"util/ISettingsObserver.h\"\n\n")
	list(APPEND content "#include \"${CLASS_NAME}_keys.h\"\n")
	list(APPEND content "#include \"${CLASS_NAME}_values.h\"\n\n")

	list(APPEND content "namespace HomeCompa {\n\n")
	list(APPEND content "class ${CLASS_NAME} \n\t: public QObject\n\t, public ISettingsObserver\n{\n")
	list(APPEND content "\tQ_OBJECT\n\n")
	foreach(name ${keys})
		list(APPEND content "\tQ_PROPERTY(QVariant ${name} READ ${name} WRITE set_${name} NOTIFY ${name}Changed)\n")
	endforeach()
	list(APPEND content "\nsignals:\n")
	foreach(name ${keys})
		list(APPEND content "\tvoid ${name}Changed() const\;\n")
	endforeach()
	list(APPEND content "\npublic:\n")
	GrabMapVariables(${SETTINGS_MAP} ${keys})
	foreach(name ${keys})
		list(APPEND content "\tvoid set_${name}(const QVariant & value)\n\t{\n\t\tm_settings->Set(Constant::${CLASS_NAME}_ns::${name}, value)\;\n\t}\n")
	endforeach()
	list(APPEND content "\npublic:\n")
	list(APPEND content "\texplicit ${CLASS_NAME}(std::shared_ptr<Settings> settings)\n\t\t: m_settings(std::move(settings))\n\t{\n\t\tm_settings->RegisterObserver(this)\;\n\t}\n")
	list(APPEND content "\t~UiSettings() override\n\t{\n\t\tm_settings->UnregisterObserver(this)\;\n\t}\n")
	list(APPEND content "\npublic:\n")
	foreach(name ${keys})
		list(APPEND content "\tQVariant ${name}() const\n\t{\n\t\treturn m_settings->Get(Constant::${CLASS_NAME}_ns::${name}, Constant::${CLASS_NAME}_ns::${name}_default)\;\n\t}\n")
	endforeach()
	list(APPEND content "\n\tQ_INVOKABLE void Reset()\n\t{\n")
	foreach(name ${keys})
		list(APPEND content "\t\tset_${name}(Constant::${CLASS_NAME}_ns::${name}_default)\;\n")
	endforeach()
	list(APPEND content "\t}\n")
	list(APPEND content "\nprivate: // SettingsObserver \n")
	list(APPEND content "\tvoid HandleValueChanged(const QString & key, const QVariant &) override\n\t{\n")
	list(APPEND content "\t\tusing Signal = void(${CLASS_NAME}::*)()const\;\n")
	list(APPEND content "\t\tstatic constexpr std::pair<const char *, Signal> s_signals[]\n\t\t{\n")
	foreach(name ${keys})
		list(APPEND content "\t\t\t{ Constant::${CLASS_NAME}_ns::${name}, &${CLASS_NAME}::${name}Changed },\n")
	endforeach()
	list(APPEND content "\t\t}\;\n")
	list(APPEND content "\t\temit (this->*FindSecond(s_signals, key.toUtf8().data(), PszComparer {}))()\;\n")
	list(APPEND content "\t}\n")
	list(APPEND content "\nprivate:\n")
	list(APPEND content "\tPropagateConstPtr<Settings, std::shared_ptr> m_settings\;\n")
	list(APPEND content "}\;\n\n")
	list(APPEND content "}\n")

	set(headerFileQt "${CMAKE_CURRENT_BINARY_DIR}/Settings/${CLASS_NAME}.h")
	set(headerFileMoc "${CMAKE_CURRENT_BINARY_DIR}/Settings/moc_${CLASS_NAME}.cpp")

	file(WRITE ${headerFileQt} ${content})
	execute_process(COMMAND ${CMAKE_COMMAND} -DINFILE=${headerFileQt} -DOUTFILE=${headerFileMoc} -P ${CMAKE_BINARY_DIR}/MocWrapper.cmake  COMMAND_ERROR_IS_FATAL ANY)

	set(keyConstants "#pragma once\n\n")
	list(APPEND keyConstants "namespace HomeCompa::Constant::${CLASS_NAME}_ns {\n\n")
	foreach(name ${keys})
		list(APPEND keyConstants "[[maybe_unused]] constexpr auto ${name} = \"${name}\"\;\n")
	endforeach()
	list(APPEND keyConstants "\n}\n")
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/Settings/${CLASS_NAME}_keys.h" ${keyConstants})

	set(valueConstants "#pragma once\n\n")
	list(APPEND valueConstants "#include <QVariant>\n\n")
	list(APPEND valueConstants "namespace HomeCompa::Constant::${CLASS_NAME}_ns {\n\n")
	foreach(name ${keys})
		list(APPEND valueConstants "[[maybe_unused]] const QVariant ${name}_default = ${${name}}\;\n")
	endforeach()
	list(APPEND valueConstants "\n}\n")
	file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/Settings/${CLASS_NAME}_values.h" ${valueConstants})

endfunction()
