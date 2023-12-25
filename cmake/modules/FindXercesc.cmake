set(xercesc_ROOT "${SDK_PATH}/xerces-c/3.2.5/x64")
string(REPLACE "\\" "/" xercesc_ROOT ${xercesc_ROOT})

add_library(xercesc SHARED IMPORTED)
set_target_properties(xercesc PROPERTIES
        # 64
        INTERFACE_INCLUDE_DIRECTORIES ${xercesc_ROOT}/include
        IMPORTED_IMPLIB_DEBUG ${xercesc_ROOT}/lib/xerces-c_3D.lib
        IMPORTED_IMPLIB_RELEASE ${xercesc_ROOT}/lib/xerces-c_3.lib
        IMPORTED_LOCATION_DEBUG ${xercesc_ROOT}/bin/xerces-c_3_2D.dll
        IMPORTED_LOCATION_RELEASE ${xercesc_ROOT}/bin/xerces-c_3_2.dll
)

set(xercesc_FOUND TRUE)
