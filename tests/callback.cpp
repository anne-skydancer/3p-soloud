#include "soloud.h"
#include "miniaudio.h"
#include <algorithm>
#include <cstdio>
#include <vector>

namespace SoLoud
{
    void soloud_miniaudio_audiomixer(ma_device*, void*, const void*, ma_uint32);
}

int main()
{
    for (unsigned int channels : {2u, 6u, 8u})
    {
        SoLoud::Soloud engine;
        if (engine.init(0, SoLoud::Soloud::NULLDRIVER, 48000, 1024, channels) != SoLoud::SO_NO_ERROR)
        {
            std::fprintf(stderr, "Offline mixer initialization failed\n");
            return 1;
        }
        ma_device device = {};
        device.pUserData = &engine;
        device.playback.channels = channels;
        for (ma_uint32 frames : {0u, 1u, 1024u, 1025u, 32769u})
        {
            std::vector<float> output(static_cast<size_t>(frames) * channels + 32, 1234.0f);
            SoLoud::soloud_miniaudio_audiomixer(&device, output.data() + 16, nullptr, frames);
            const auto begin = output.begin() + 16;
            const auto end = output.end() - 16;
            const bool guards = std::all_of(output.begin(), begin, [](float value) { return value == 1234.0f; }) &&
                std::all_of(end, output.end(), [](float value) { return value == 1234.0f; });
            const bool silence = std::all_of(begin, end, [](float value) { return value == 0.0f; });
            if (!guards || !silence)
            {
                std::fprintf(stderr, "Callback failed: %u channels, %u frames\n", channels, frames);
                return 1;
            }
        }
        engine.deinit();
    }
    std::puts("PASS: callback fills stereo/5.1/7.1 output and preserves guard samples.");
    return 0;
}