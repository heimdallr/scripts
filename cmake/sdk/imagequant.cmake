set(imagequant_ROOT "${SDK_PATH}/imagequant")
string(REPLACE "\\" "/" imagequant_ROOT ${imagequant_ROOT})

set(imagequant_INCLUDE_DIR "${imagequant_ROOT}/include")
set(imagequant_LIB_DIR "${imagequant_ROOT}/x64/lib")
set(imagequant_BIN_DIR "${imagequant_ROOT}/x64/bin")

add_library(imagequant SHARED IMPORTED)
set_target_properties(imagequant PROPERTIES
        # 64
        INTERFACE_INCLUDE_DIRECTORIES ${imagequant_INCLUDE_DIR}
        IMPORTED_IMPLIB_DEBUG ${imagequant_LIB_DIR}/imagequant.dll.lib
        IMPORTED_IMPLIB_RELEASE ${imagequant_LIB_DIR}/imagequant.dll.lib
        IMPORTED_LOCATION_DEBUG ${imagequant_BIN_DIR}/imagequant.dll
        IMPORTED_LOCATION_RELEASE ${imagequant_BIN_DIR}/imagequant.dll
)

set(imagequant_FOUND TRUE)
