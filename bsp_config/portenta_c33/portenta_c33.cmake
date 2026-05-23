set(NEXUS_BOARD_ARCH "arm")
set(NEXUS_BOARD_CPU "cortex-m33")

set(NEXUS_BOARD_CPU_FLAGS
    -mcpu=cortex-m33
    -mthumb
)

set(NEXUS_BOARD_LINKER_SCRIPT "${CMAKE_CURRENT_LIST_DIR}/linker_unified.ld")

set(NEXUS_BOARD_INCLUDE_DIRS
    ${CMAKE_SOURCE_DIR}/bsp_config/common/include
    ${CMAKE_SOURCE_DIR}/bsp_config/portenta_c33
    ${CMAKE_CURRENT_LIST_DIR}
)
