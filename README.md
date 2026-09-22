# 3p-soloud

Standalone Windows x64 and Linux x64 autobuild dependency for Vulkanstorm. SoLoud is built
outside the viewer, using MSVC's dynamic release runtime (/MD). No external
SOLOUD_ROOT checkout is required by the viewer.

## Source and Patch

Upstream: https://github.com/jarikomppa/soloud

Pinned revision: `e82fd32c1f62183922f08c14c814a02b58db1873`.

`patches/miniaudio-bounded-mix.patch` is an adaptation of the callback fix in
the archival VulkanStorm revision `e26eeab374`,
`indra/soloud/src/backend/miniaudio/soloud_miniaudio.cpp`.
It splits device callbacks into at most 1,024 frames per mixer call, advancing
the output pointer by the interleaved channel count. This protects SoLoud's
bounded scratch buffers when a device requests a large multichannel buffer.
The distributed library is a modified upstream build.

`patches/miniaudio-device-selection.patch` preserves the archive's selected
output device, native sample rate/channel count, and 40 ms period request.
It rejects unsupported channel layouts and reports device-start failure.
Device-selection globals must only be changed with the backend stopped or
before initialization; the viewer serializes device restarts.

The archive's hard-coded raw-audio capture path, volatile callback telemetry,
and scheduler changes are not imported. Viewer code must not reference the
archived telemetry symbols. Hardware playback and device switching still
require operator qualification.

## Build and Package

Prerequisites: Git, CMake 3.24+, Visual Studio 2022 C++ tools, Windows SDK,
and autobuild.

```powershell
autobuild build -A 64 -c release
autobuild package -A 64 -c release --archive-format tzst
```

The build fetches the pinned source, applies the patch, compiles the library,
runs the callback regression test, and installs into `stage/`. The package
contains `lib/release/soloud.lib`, `include/soloud/`, license notices, and a
version record. MiniAudio, NoSound, and the offline Null backend are enabled.
Headers for unbuilt optional audio sources do not imply compiled support;
the compiled sources are core, WAV/WAV-stream decoders, and these backends.

The test invokes the real MiniAudio callback with stereo, 5.1 and 7.1 output
and 0, 1, 1,024, 1,025 and 32,769 frame requests. It verifies silence coverage
and guard samples without opening an audio device. It does not qualify live
device output or all viewer audio features.

Linux uses GCC/Clang, CMake 3.24+, Make, Git and autobuild, with the same build
commands. It produces position-independent `lib/release/libsoloud.a`; consumers
must link the platform thread and dynamic-loader libraries. CI builds on Ubuntu
22.04 and Windows 2022 and runs the same headless callback test before packaging.
Linux hardware playback and device switching remain unqualified.

Release publication and
the viewer autobuild URL/hash entry must use the actual generated archive;
no speculative release URL is provided here.
