#ifndef WHISPER_WRAPPER_H
#define WHISPER_WRAPPER_H

#include "whisper.h"

#ifdef __cplusplus
extern "C" {
#endif

struct whisper_context_params my_whisper_context_default_params();

struct whisper_context *my_whisper_init_from_file_with_params(const char *path_model, struct whisper_context_params cparams);

void my_whisper_free(struct whisper_context *ctx);

struct whisper_full_params my_whisper_full_default_params(enum whisper_sampling_strategy strategy);

int my_whisper_full(
    struct whisper_context * ctx,
    struct whisper_full_params params,
    const float * samples,
    int n_samples);

int my_whisper_full_n_segments(struct whisper_context * ctx);

const char *my_whisper_full_get_segment_text(struct whisper_context *ctx, int i_segment);

#ifdef __cplusplus
}
#endif

#endif // WHISPER_WRAPPER_H