set(7z_ROOT "${SDK_PATH}/7z/x64")
string(REPLACE "\\" "/" 7z_ROOT ${7z_ROOT})
#message(FATAL_ERROR "${7z_ROOT}/bin/7za.dll -> ${CMAKE_BINARY_DIR}/bin/${CMAKE_BUILD_TYPE}")
file(COPY ${7z_ROOT}/bin/7za.dll DESTINATION ${CMAKE_BINARY_DIR}/bin/${CMAKE_BUILD_TYPE})
