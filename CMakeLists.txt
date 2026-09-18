cmake_minimum_required(VERSION 3.24)
project(soloud_package VERSION 1.0 LANGUAGES C CXX)

include(FetchContent)
include(CTest)
find_package(Git REQUIRED)

set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
FetchContent_Declare(soloud_source
    GIT_REPOSITORY https://github.com/jarikomppa/soloud.git
    GIT_TAG e82fd32c1f62183922f08c14c814a02b58db1873
    GIT_PROGRESS TRUE
    PATCH_COMMAND "${CMAKE_COMMAND}" "-DGIT_EXECUTABLE=${GIT_EXECUTABLE}"
        "-DSOURCE_DIR=<SOURCE_DIR>"
        "-DPATCH_FILE=${CMAKE_CURRENT_SOURCE_DIR}/patches/miniaudio-bounded-mix.patch"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/ApplyPatch.cmake"
        COMMAND "${CMAKE_COMMAND}" "-DGIT_EXECUTABLE=${GIT_EXECUTABLE}"
        "-DSOURCE_DIR=<SOURCE_DIR>"
        "-DPATCH_FILE=${CMAKE_CURRENT_SOURCE_DIR}/patches/miniaudio-device-selection.patch"
        -P "${CMAKE_CURRENT_SOURCE_DIR}/ApplyPatch.cmake"
)
FetchContent_MakeAvailable(soloud_source)

file(GLOB soloud_core CONFIGURE_DEPENDS "${soloud_source_SOURCE_DIR}/src/core/*.cpp")
add_library(soloud STATIC
    ${soloud_core}
    "${soloud_source_SOURCE_DIR}/src/audiosource/wav/dr_impl.cpp"
    "${soloud_source_SOURCE_DIR}/src/audiosource/wav/soloud_wav.cpp"
    "${soloud_source_SOURCE_DIR}/src/audiosource/wav/soloud_wavstream.cpp"
    "${soloud_source_SOURCE_DIR}/src/audiosource/wav/stb_vorbis.c"
    "${soloud_source_SOURCE_DIR}/src/backend/miniaudio/soloud_miniaudio.cpp"
    "${soloud_source_SOURCE_DIR}/src/backend/nosound/soloud_nosound.cpp"
    "${soloud_source_SOURCE_DIR}/src/backend/null/soloud_null.cpp"
)
target_compile_features(soloud PUBLIC cxx_std_11)
target_compile_definitions(soloud PRIVATE WITH_MINIAUDIO=1 WITH_NOSOUND=1 WITH_NULL=1)
target_include_directories(soloud PUBLIC
    "${soloud_source_SOURCE_DIR}/include"
    "${soloud_source_SOURCE_DIR}/src/backend/miniaudio"
)
if(UNIX)
    find_package(Threads REQUIRED)
    target_link_libraries(soloud PUBLIC Threads::Threads ${CMAKE_DL_LIBS})
endif()

install(TARGETS soloud ARCHIVE DESTINATION lib/release)
install(DIRECTORY "${soloud_source_SOURCE_DIR}/include/" DESTINATION include/soloud
    FILES_MATCHING PATTERN "*.h")
install(FILES "${soloud_source_SOURCE_DIR}/src/backend/miniaudio/miniaudio.h"
    DESTINATION include/soloud)
install(FILES "${soloud_source_SOURCE_DIR}/LICENSE" DESTINATION LICENSES RENAME soloud.txt)
install(FILES "${soloud_source_SOURCE_DIR}/src/backend/miniaudio/miniaudio.h"
    DESTINATION LICENSES RENAME soloud-miniaudio.txt)
install(FILES "${CMAKE_CURRENT_SOURCE_DIR}/VERSION.txt" DESTINATION .)

if(BUILD_TESTING)
    add_executable(soloud_callback_test tests/callback.cpp)
    target_link_libraries(soloud_callback_test PRIVATE soloud)
    add_test(NAME soloud_callback_bounds COMMAND soloud_callback_test)
endif()