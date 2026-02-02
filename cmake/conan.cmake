include_guard(GLOBAL)

function(conan_install path profile)
	set(CONAN_ADDITIONAL_PARAMETERS)
	if(${CMAKE_GENERATOR} STREQUAL "Ninja")
		set(CONAN_ADDITIONAL_PARAMETERS "-c tools.cmake.cmaketoolchain:generator=Ninja")
	endif()

	execute_process(
		COMMAND conan install ${path}
			--output-folder ${CMAKE_BINARY_DIR}
			-pr:b ${profile}
			-pr:h ${profile}
			--build=missing
			${CONAN_ADDITIONAL_PARAMETERS}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
	)

	set (CMAKE_POLICY_DEFAULT_CMP0091 NEW)
	cmake_policy(SET CMP0091 NEW)
endfunction()
