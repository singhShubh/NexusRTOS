if(NOT DEFINED NEXUS_OBJCOPY OR NEXUS_OBJCOPY STREQUAL "")
    message(FATAL_ERROR "ExtractWorldBins: NEXUS_OBJCOPY is required")
endif()
if(NOT DEFINED NEXUS_OBJDUMP OR NEXUS_OBJDUMP STREQUAL "")
    message(FATAL_ERROR "ExtractWorldBins: NEXUS_OBJDUMP is required")
endif()
if(NOT DEFINED NEXUS_ELF OR NEXUS_ELF STREQUAL "")
    message(FATAL_ERROR "ExtractWorldBins: NEXUS_ELF is required")
endif()
if(NOT EXISTS "${NEXUS_ELF}")
    message(FATAL_ERROR "ExtractWorldBins: ELF not found: ${NEXUS_ELF}")
endif()
if(NOT DEFINED NEXUS_NONSECURE_BIN OR NEXUS_NONSECURE_BIN STREQUAL "")
    message(FATAL_ERROR "ExtractWorldBins: NEXUS_NONSECURE_BIN is required")
endif()
if(NOT DEFINED NEXUS_SECURE_BIN)
    set(NEXUS_SECURE_BIN "")
endif()
if(NOT DEFINED NEXUS_ENABLE_SECURE_WORLD)
    set(NEXUS_ENABLE_SECURE_WORLD OFF)
endif()

execute_process(
    COMMAND "${NEXUS_OBJDUMP}" -h "${NEXUS_ELF}"
    RESULT_VARIABLE _objdump_result
    OUTPUT_VARIABLE _objdump_output
    ERROR_VARIABLE _objdump_error
)
if(NOT _objdump_result EQUAL 0)
    message(FATAL_ERROR
        "ExtractWorldBins: objdump failed for '${NEXUS_ELF}'.\n"
        "stderr:\n${_objdump_error}")
endif()

string(REPLACE "\r\n" "\n" _objdump_output "${_objdump_output}")
string(REPLACE "\n" ";" _objdump_lines "${_objdump_output}")

set(_nonsecure_sections)
set(_secure_sections)
set(_pending_section "")

foreach(_line_raw IN LISTS _objdump_lines)
    string(STRIP "${_line_raw}" _line)
    if(_line STREQUAL "")
        continue()
    endif()

    # Section header line format from GNU objdump -h:
    # <idx> <name> <size> <vma> <lma> <file_off> <align>
    if(_line MATCHES "^[0-9]+[ \t]+([^ \t]+)[ \t]+[0-9A-Fa-f]+[ \t]+[0-9A-Fa-f]+[ \t]+[0-9A-Fa-f]+[ \t]+[0-9A-Fa-f]+[ \t]+2\\*\\*[0-9]+$")
        set(_pending_section "${CMAKE_MATCH_1}")
        continue()
    endif()

    # Flags line follows the section header line. Keep only sections that are
    # present in the load image (ALLOC + CONTENTS), then classify by world tag.
    if(NOT _pending_section STREQUAL "")
        if(_line MATCHES "ALLOC" AND _line MATCHES "CONTENTS")
            if(_pending_section MATCHES "(^|\\.)nonsecure($|\\.)")
                list(APPEND _nonsecure_sections "${_pending_section}")
            elseif(_pending_section MATCHES "(^|\\.)secure($|\\.)")
                list(APPEND _secure_sections "${_pending_section}")
            endif()
        endif()
        set(_pending_section "")
    endif()
endforeach()

list(REMOVE_DUPLICATES _nonsecure_sections)
list(REMOVE_DUPLICATES _secure_sections)

function(_nexus_objcopy_sections output_bin section_var world_label)
    if(NOT DEFINED ${section_var} OR "${${section_var}}" STREQUAL "")
        message(FATAL_ERROR
            "ExtractWorldBins: no sections provided for ${world_label} output '${output_bin}'.")
    endif()

    set(_cmd "${NEXUS_OBJCOPY}" "-O" "binary")
    foreach(_sec IN LISTS ${section_var})
        list(APPEND _cmd "-j" "${_sec}")
    endforeach()
    list(APPEND _cmd "${NEXUS_ELF}" "${output_bin}")

    execute_process(
        COMMAND ${_cmd}
        RESULT_VARIABLE _objcopy_result
        ERROR_VARIABLE _objcopy_error
    )
    if(NOT _objcopy_result EQUAL 0)
        message(FATAL_ERROR
            "ExtractWorldBins: objcopy failed for ${world_label} image '${output_bin}'.\n"
            "stderr:\n${_objcopy_error}")
    endif()
endfunction()

if(_nonsecure_sections)
    string(JOIN ", " _nonsecure_log ${_nonsecure_sections})
    message(STATUS "ExtractWorldBins: non-secure sections => ${_nonsecure_log}")
    _nexus_objcopy_sections("${NEXUS_NONSECURE_BIN}" _nonsecure_sections "non-secure")
else()
    message(WARNING
        "ExtractWorldBins: no non-secure allocatable sections found in '${NEXUS_ELF}'. "
        "Creating empty non-secure image '${NEXUS_NONSECURE_BIN}'.")
    file(WRITE "${NEXUS_NONSECURE_BIN}" "")
endif()

if(NEXUS_ENABLE_SECURE_WORLD)
    if(NEXUS_SECURE_BIN STREQUAL "")
        message(FATAL_ERROR
            "ExtractWorldBins: NEXUS_SECURE_BIN is required when secure world is enabled.")
    endif()

    if(_secure_sections)
        string(JOIN ", " _secure_log ${_secure_sections})
        message(STATUS "ExtractWorldBins: secure sections => ${_secure_log}")
        _nexus_objcopy_sections("${NEXUS_SECURE_BIN}" _secure_sections "secure")
    else()
        message(WARNING
            "ExtractWorldBins: secure build enabled but no secure allocatable sections found in '${NEXUS_ELF}'. "
            "Creating empty secure image '${NEXUS_SECURE_BIN}'.")
        file(WRITE "${NEXUS_SECURE_BIN}" "")
    endif()
elseif(NOT NEXUS_SECURE_BIN STREQUAL "")
    # Avoid stale secure images when secure world is disabled.
    file(REMOVE "${NEXUS_SECURE_BIN}")
endif()
