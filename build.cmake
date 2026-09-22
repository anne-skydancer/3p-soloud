cmake_minimum_required(VERSION 3.24)
set(root "${CMAKE_CURRENT_LIST_DIR}")
if(CMAKE_HOST_WIN32)
    set(generator -G "Visual Studio 17 2022" -A x64)
elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL "Linux")
    set(generator -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release)
else()
    message(FATAL_ERROR "SoLoud packaging supports Windows x64 and Linux x64")
endif()
execute_process(COMMAND "${CMAKE_COMMAND}" -S "${root}" -B "${root}/build"
    ${generator} "-DCMAKE_INSTALL_PREFIX=${root}/stage"
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" --build "${root}/build" --config Release --parallel 3
    COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_CTEST_COMMAND}" --test-dir "${root}/build"
    -C Release --output-on-failure COMMAND_ERROR_IS_FATAL ANY)
execute_process(COMMAND "${CMAKE_COMMAND}" --install "${root}/build" --config Release
    COMMAND_ERROR_IS_FATAL ANY)
