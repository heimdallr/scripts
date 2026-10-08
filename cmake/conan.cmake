include_guard(GLOBAL)

message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}")
if("${CONAN_PROFILE}" STREQUAL "")
	if(${CMAKE_CXX_COMPILER_ID} STREQUAL MSVC)
		set(CONAN_PROFILE msvc2022_${PLATFORM})
	elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL GNU)
		set(CONAN_PROFILE gcc14_x86_64)
	elseif(${CMAKE_CXX_COMPILER_ID} STREQUAL AppleClang)
		set(CONAN_PROFILE apple_clang_armv8)
	else()
		message(FATAL_ERROR "Unsupported compiler: ${CMAKE_CXX_COMPILER_ID}")
	endif()
endif()

function(conan_install path profile)
	set(CONAN_ADDITIONAL_PARAMETERS)
	if(${CMAKE_GENERATOR} STREQUAL "Ninja")
		list(APPEND CONAN_ADDITIONAL_PARAMETERS -c tools.cmake.cmaketoolchain:generator=Ninja)
	endif()
	if(APPLE)
		if("${CMAKE_OSX_SYSROOT}" STREQUAL "" OR "${CMAKE_OSX_SYSROOT}" STREQUAL "macosx")
			execute_process(
				COMMAND xcrun --sdk macosx --show-sdk-path
				OUTPUT_VARIABLE APPLE_SDK_PATH
				OUTPUT_STRIP_TRAILING_WHITESPACE
				RESULT_VARIABLE APPLE_SDK_PATH_RESULT
			)
			if(NOT APPLE_SDK_PATH_RESULT EQUAL 0 OR "${APPLE_SDK_PATH}" STREQUAL "")
				message(FATAL_ERROR "Failed to resolve macOS SDK path with xcrun")
			endif()
			set(CMAKE_OSX_SYSROOT "${APPLE_SDK_PATH}" CACHE STRING "" FORCE)
		endif()
		list(APPEND CONAN_ADDITIONAL_PARAMETERS -c "tools.apple:sdk_path=${CMAKE_OSX_SYSROOT}")
	endif()

	execute_process(
		COMMAND conan install ${path}
			--output-folder ${CMAKE_BINARY_DIR}
			-pr:b ${profile}
			-pr:h ${profile}
			--build=missing
			${CONAN_ADDITIONAL_PARAMETERS}
		WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
		RESULT_VARIABLE CONAN_INSTALL_RESULT
	)
	if(NOT CONAN_INSTALL_RESULT EQUAL 0)
		message(FATAL_ERROR "conan install failed with exit code ${CONAN_INSTALL_RESULT}")
	endif()

	set (CMAKE_POLICY_DEFAULT_CMP0091 NEW)
	cmake_policy(SET CMP0091 NEW)
endfunction()
