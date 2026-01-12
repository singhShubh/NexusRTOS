    cmake_minimum_required(VERSION 3.20)
    project(NexusRTOS LANGUAGES C ASM)

    include(build/cmake/NexusCommon.cmake)
    include(build/cmake/BoardConfig.cmake)
    include(build/cmake/NexusDummySources.cmake)
    include(build/cmake/NexusModule.cmake)

    nexus_enforce_out_of_source()
    nexus_set_default_build_type(Debug)
    nexus_set_output_dirs()

    option(NEXUS_ENABLE_DUMMY_LINK "Generate tiny build-local stub sources so the scaffold can link" ON)

    if(NOT NEXUS_BOARD)
        nexus_list_boards(_boards)
        message(FATAL_ERROR
            "NEXUS_BOARD is not set. Available boards: ${_boards}"
            "Example: -DNEXUS_BOARD=mps2_an505")
    endif()

    nexus_load_board(${NEXUS_BOARD})

    if(NOT EXISTS "${NEXUS_BOARD_ARCH_CONFIG}")
        message(FATAL_ERROR
            "Architecture config file not found for arch '${NEXUS_BOARD_ARCH}' and cpu '${NEXUS_BOARD_CPU}': ${NEXUS_BOARD_ARCH_CONFIG}")
    endif()
    include(${NEXUS_BOARD_ARCH_CONFIG})

    add_library(nexus_project_options INTERFACE)
    target_compile_features(nexus_project_options INTERFACE c_std_11)
    target_include_directories(nexus_project_options INTERFACE
        ${CMAKE_SOURCE_DIR}/include
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

    # Order matters where targets depend on earlier public API targets.
    add_subdirectory(kernel)
    add_subdirectory(bsp/${NEXUS_BOARD})
    add_subdirectory(drivers)
    add_subdirectory(services)
    add_subdirectory(arch/arm/common)
    add_subdirectory(${NEXUS_BOARD_ARCH_DIR})
    add_subdirectory(security)
    add_subdirectory(boot)
    add_subdirectory(app)

    if(NEXUS_ENABLE_DUMMY_LINK)
       nexus_generate_dummy_sources(NEXUS_GENERATED_DUMMY_SOURCES)
    else()
        set(NEXUS_GENERATED_DUMMY_SOURCES)
    endif()

    add_executable(nexus_${NEXUS_BOARD}
        ${NEXUS_GENERATED_DUMMY_SOURCES}
    )

    target_link_libraries(nexus_${NEXUS_BOARD} PRIVATE
        nexus_project_options
        nexus_bsp
        nexus_drivers
        nexus_services
        nexus_arch_common
        nexus_arch
        nexus_security
        nexus_boot
        nexus_kernel_impl
        nexus_app
    )

    set_target_properties(nexus_${NEXUS_BOARD} PROPERTIES
        OUTPUT_NAME nexus_${NEXUS_BOARD}
        SUFFIX .elf
        RUNTIME_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
        ARCHIVE_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
        LIBRARY_OUTPUT_DIRECTORY ${NEXUS_ARTIFACT_DIR}
    )

    target_link_options(nexus_${NEXUS_BOARD} PRIVATE
        ${NEXUS_BOARD_CPU_FLAGS}
        -T ${NEXUS_BOARD_LINKER_SCRIPT}
        -Wl,-Map,${NEXUS_ARTIFACT_DIR}/nexus_${NEXUS_BOARD}.map
        -Wl,--gc-sections
        -nostartfiles
    )

    if(CMAKE_SIZE)
        add_custom_command(TARGET nexus_${NEXUS_BOARD} POST_BUILD
            COMMAND ${CMAKE_SIZE} $<TARGET_FILE:nexus_${NEXUS_BOARD}>
            COMMENT "Printing ELF section sizes"
            VERBATIM
        )
    endif()
