cmake_minimum_required(VERSION 3.20)

# Shared CMake helper functions used by root and modules.
include(build/cmake/NexusCommon.cmake)
include(build/cmake/BoardConfig.cmake)

# Prevent accidental in-source builds.
nexus_enforce_out_of_source()

# Board must be selected explicitly to keep configuration deterministic.
if(NOT NEXUS_BOARD)
    nexus_list_boards(_boards)
    message(FATAL_ERROR
        "NEXUS_BOARD is not set. Available boards: ${_boards}\n"
        "Example: -DNEXUS_BOARD=mps2_an505")
endif()

# Enforce the expected build directory layout: build/<board>/<BuildType>.
nexus_enforce_board_build_dir(${NEXUS_BOARD})

project(NexusRTOS LANGUAGES C ASM)

# Build helper modules (target helpers and scaffold dummy source generator).
include(build/cmake/NexusDummySources.cmake)
include(build/cmake/NexusModule.cmake)

nexus_set_default_build_type(Debug)

option(
    NEXUS_ENABLE_DUMMY_LINK
    "Generate tiny build-local stub sources so the scaffold can link"
    ON
)

# Load board-specific configuration and derive arch paths.
nexus_load_board(${NEXUS_BOARD})
nexus_set_output_dirs()
set(NEXUS_ENABLE_SECURE_WORLD ${NEXUS_BOARD_ENABLE_SECURE_WORLD})

if(NOT EXISTS "${NEXUS_BOARD_ARCH_CONFIG}")
    message(FATAL_ERROR
        "Architecture config file not found for arch '${NEXUS_BOARD_ARCH}' and cpu '${NEXUS_BOARD_CPU}': ${NEXUS_BOARD_ARCH_CONFIG}")
endif()
include(${NEXUS_BOARD_ARCH_CONFIG})

if(NOT EXISTS "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_COMMON_DIR}/CMakeLists.txt")
    message(FATAL_ERROR
        "Architecture common directory not found for arch '${NEXUS_BOARD_ARCH}': "
        "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_ARCH_COMMON_DIR}")
endif()

if(NEXUS_ENABLE_SECURE_WORLD AND NOT EXISTS "${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_SECURE_ARCH_DIR}/CMakeLists.txt")
    message(FATAL_ERROR
        "Secure architecture directory not found for arch '${NEXUS_BOARD_ARCH}' and cpu '${NEXUS_BOARD_CPU}' "
        "while secure build support is enabled: ${CMAKE_SOURCE_DIR}/${NEXUS_BOARD_SECURE_ARCH_DIR}")
endif()

# Common compile/link defaults inherited by all project modules.
add_library(nexus_common_headers INTERFACE)
target_include_directories(nexus_common_headers INTERFACE
    ${CMAKE_SOURCE_DIR}/include
)

add_library(nexus_project_options INTERFACE)
target_compile_features(nexus_project_options INTERFACE c_std_11)
target_link_libraries(nexus_project_options INTERFACE
    nexus_common_headers
)
target_include_directories(nexus_project_options INTERFACE
    ${NEXUS_BOARD_INCLUDE_DIRS}
)
target_compile_options(nexus_project_options INTERFACE
    ${NEXUS_BOARD_CPU_FLAGS}
    ${NEXUS_ARCH_COMMON_COMPILE_FLAGS}
    -ffreestanding
    -fno-builtin
    -nostdlib
    -fdata-sections
    -ffunction-sections
    -fno-common
    -Wall
    -Wextra
    -Werror=implicit-function-declaration
    $<$<CONFIG:Debug>:-Og -g3>
    $<$<CONFIG:Release>:-Os -g0>
)

# Compose module graph. Order matters where targets depend on earlier API targets.
add_subdirectory(os/kernel)
add_subdirectory(bsp/${NEXUS_BOARD})
add_subdirectory(drivers)
add_subdirectory(${NEXUS_BOARD_ARCH_COMMON_DIR})
add_subdirectory(${NEXUS_BOARD_ARCH_DIR})
if(NEXUS_ENABLE_SECURE_WORLD)
    add_subdirectory(secure)
endif()
add_subdirectory(os/boot)
add_subdirectory(app)

if(NEXUS_ENABLE_DUMMY_LINK)
    nexus_generate_dummy_sources(NEXUS_GENERATED_DUMMY_SOURCES)
else()
    set(NEXUS_GENERATED_DUMMY_SOURCES)
endif()

# Final firmware executable that links all module aggregators.
add_executable(nexus_${NEXUS_BOARD}
    ${NEXUS_GENERATED_DUMMY_SOURCES}
)
set(NEXUS_EXECUTABLE_DEPS
    nexus_project_options
    nexus_bsp
    nexus_drivers
    nexus_arch_common
    nexus_arch
    nexus_boot
)
if(NEXUS_ENABLE_SECURE_WORLD)
    list(APPEND NEXUS_EXECUTABLE_DEPS nexus_secure)
endif()
list(APPEND NEXUS_EXECUTABLE_DEPS
    nexus_kernel_impl
    nexus_app
)

target_link_libraries(nexus_${NEXUS_BOARD} PRIVATE
    ${NEXUS_EXECUTABLE_DEPS}
)
set_target_properties(nexus_${NEXUS_BOARD} PROPERTIES
    OUTPUT_NAME nexus_${NEXUS_BOARD}
    SUFFIX .elf
    RUNTIME_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
    ARCHIVE_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
    LIBRARY_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
)

set(NEXUS_UNIFIED_ELF ${NEXUS_ARTIFACT_DIR}/nexus_${NEXUS_BOARD}.elf)
set(NEXUS_SECURE_BIN ${NEXUS_ARTIFACT_DIR}/nexus_${NEXUS_BOARD}_secure.bin)
set(NEXUS_NONSECURE_BIN ${NEXUS_ARTIFACT_DIR}/nexus_${NEXUS_BOARD}_nonsecure.bin)

target_link_options(nexus_${NEXUS_BOARD} PRIVATE
    ${NEXUS_BOARD_CPU_FLAGS}
    -T ${NEXUS_BOARD_LINKER_SCRIPT}
    -Wl,-Map,${NEXUS_ARTIFACT_DIR}/nexus_${NEXUS_BOARD}.map
    -Wl,--gc-sections
    -nostartfiles
)

# Post-build diagnostics and binary image extraction.
if(CMAKE_SIZE)
    add_custom_command(TARGET nexus_${NEXUS_BOARD} POST_BUILD
        COMMAND ${CMAKE_SIZE} $<TARGET_FILE:nexus_${NEXUS_BOARD}>
        COMMENT "Printing ELF section sizes"
        VERBATIM
    )
endif()

if(CMAKE_OBJCOPY AND CMAKE_OBJDUMP)
    add_custom_command(TARGET nexus_${NEXUS_BOARD} POST_BUILD
        COMMAND ${CMAKE_COMMAND}
            -DNEXUS_OBJCOPY=${CMAKE_OBJCOPY}
            -DNEXUS_OBJDUMP=${CMAKE_OBJDUMP}
            -DNEXUS_ELF=${NEXUS_UNIFIED_ELF}
            -DNEXUS_SECURE_BIN=${NEXUS_SECURE_BIN}
            -DNEXUS_NONSECURE_BIN=${NEXUS_NONSECURE_BIN}
            -DNEXUS_ENABLE_SECURE_WORLD=${NEXUS_ENABLE_SECURE_WORLD}
            -P ${CMAKE_SOURCE_DIR}/build/cmake/ExtractWorldBins.cmake
        COMMENT "Generating world-specific binary images"
        VERBATIM
    )
elseif(CMAKE_OBJCOPY)
    message(WARNING
        "CMAKE_OBJCOPY is set but CMAKE_OBJDUMP is missing. "
        "Skipping world-specific binary image generation.")
endif()
