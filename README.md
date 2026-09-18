# 3p-soloud

Standalone Windows x64 autobuild dependency for Vulkanstorm. SoLoud is built
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

The archive's hard-coded raw-audio capture path, volatile callback telemetry,
device-selection globals, and scheduler changes are not imported by this
safety patch. The archived viewer adapter must not be linked unchanged until
its custom device-selection/telemetry ABI has been handled explicitly.

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

Only Windows x64 packaging is currently qualified. Release publication and
the viewer autobuild URL/hash entry must use the actual generated archive;
no speculative release URL is provided here.