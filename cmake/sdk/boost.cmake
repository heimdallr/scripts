include_guard(GLOBAL)

# Подключаем boost
if(NOT DEFINED ENV{BOOST_ROOT})
	set(ENV{BOOST_ROOT} ${SDK_PATH}/boost/boost_1_82_0)
endif()

add_library(boost INTERFACE IMPORTED)
set_target_properties(boost PROPERTIES
	INTERFACE_INCLUDE_DIRECTORIES $ENV{BOOST_ROOT}
)
