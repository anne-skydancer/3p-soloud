cmake_minimum_required(VERSION 3.24)
execute_process(COMMAND "${GIT_EXECUTABLE}" apply --check --ignore-space-change "${PATCH_FILE}"
    WORKING_DIRECTORY "${SOURCE_DIR}" RESULT_VARIABLE forward_result
    OUTPUT_QUIET ERROR_QUIET)
if(forward_result EQUAL 0)
    execute_process(COMMAND "${GIT_EXECUTABLE}" apply --ignore-space-change --whitespace=error "${PATCH_FILE}"
        WORKING_DIRECTORY "${SOURCE_DIR}" COMMAND_ERROR_IS_FATAL ANY)
else()
    execute_process(COMMAND "${GIT_EXECUTABLE}" apply --reverse --check --ignore-space-change "${PATCH_FILE}"
        WORKING_DIRECTORY "${SOURCE_DIR}" RESULT_VARIABLE reverse_result
        OUTPUT_QUIET ERROR_QUIET)
    if(NOT reverse_result EQUAL 0)
        message(FATAL_ERROR "Source neither matches the pinned patch input nor has the exact patch applied: ${PATCH_FILE}")
    endif()
endif()