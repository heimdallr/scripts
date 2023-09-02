add_library(Hypodermic INTERFACE IMPORTED)

set_target_properties(Hypodermic PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES ${SDK_PATH}/Hypodermic/src
)
set_target_properties(Hypodermic PROPERTIES
	INTERFACE_LINK_LIBRARIES boost
)

set(Hypodermic_FOUND TRUE)
