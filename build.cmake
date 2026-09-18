cmake_minimum_required(VERSION 3.24)
set(root "${CMAKE_CURRENT_LIST_DIR}")
execute_process(COMMAND "${CMAKE_COMMAND}" -S "${root}" -B "${root}/build"
    -G "Visual Studio 17 2022" -A x64 "-DCMAKE_INSTALL_PREFIX=${root}/stage"
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" --build "${root}/build" --config Release
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_CTEST_COMMAND}" --test-dir "${root}/build"
    -C Release --output-on-failure COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${root}/build" --config Release
    COMMAND_ERROR_IS_FATAL ANY)