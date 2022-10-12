# Подготовка workspace для win сборки
message(STATUS "Prepare workspace..." )

file(GLOB PREPARE_WORKSPACE	${PREPARE_WORKSPACE_FILES})

file(COPY ${PREPARE_WORKSPACE} DESTINATION ${BIN_DIR} NO_SOURCE_PERMISSIONS)

if (QT_ROOT_PATH)
	CopyQtPlugins()
endif()
