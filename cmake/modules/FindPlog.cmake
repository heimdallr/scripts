add_library(plog INTERFACE IMPORTED)

set_target_properties(plog PROPERTIES
        INTERFACE_INCLUDE_DIRECTORIES ${SDK_PATH}/plog/src/include
)
set(plog_FOUND TRUE)
