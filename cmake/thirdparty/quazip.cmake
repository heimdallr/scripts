set(pkg quazip)

AddThirdpartyModule(NAME ${pkg}
	)

set(quazip_ROOT "${CMAKE_CURRENT_BINARY_DIR}-thirdparty")

LinkSdkLibrary(quazip TARGET_NAME ${pkg} LIBS ${pkg} DLLS ${pkg}
	[ WIN32 HAS_DEBUG DEBUG_SUFFIX "d" ]
	)
