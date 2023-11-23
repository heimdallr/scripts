include_guard(GLOBAL)

# Подключаем SDK
if (NOT DEFINED SDK_PATH)
	set(SDK_PATH $ENV{SDK_PATH})
	if (NOT SDK_PATH)
		set(SDK_PATH D:/sdk)
	endif ()
endif ()

include(${CMAKE_CURRENT_LIST_DIR}/sdk/qt.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/sdk/boost.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/sdk/zlib.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/sdk/icu.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/sdk/7z.cmake)
