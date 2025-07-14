#include "whisper_wrapper.h"
#include "whisper.h"

struct whisper_context_params my_whisper_context_default_params() {
    return whisper_context_default_params();
}

struct whisper_context *my_whisper_init_from_file_with_params(const char *path_model, struct whisper_context_params cparams) {
    return whisper_init_from_file_with_params(path_model, cparams);
}

void my_whisper_free(struct whisper_context *ctx) {
    whisper_free(ctx);
}

struct whisper_full_params my_whisper_full_default_params(enum whisper_sampling_strategy strategy) {
    return whisper_full_default_params(strategy);
}

int my_whisper_full(
    struct whisper_context * ctx,
    struct whisper_full_params params,
    const float * samples,
    int n_samples) {
    return whisper_full(ctx, params, samples, n_samples);
}

int my_whisper_full_n_segments(
    struct whisper_context * ctx) {
    return whisper_full_n_segments(ctx);
}

const char *my_whisper_full_get_segment_text(struct whisper_context *ctx, int i_segment) {
    return whisper_full_get_segment_text(ctx, i_segment);
}