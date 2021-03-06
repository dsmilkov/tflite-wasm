/* Copyright 2018 The TensorFlow Authors. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
==============================================================================*/

#include <emscripten.h>
#include "tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/no_micro_features_data.h"
#include "tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/tiny_conv_micro_features_model_data.h"
#include "tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/yes_micro_features_data.h"
#include "tensorflow/lite/experimental/micro/kernels/all_ops_resolver.h"
#include "tensorflow/lite/experimental/micro/micro_error_reporter.h"
#include "tensorflow/lite/experimental/micro/micro_interpreter.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/version.h"

tflite::MicroErrorReporter micro_reporter;
tflite::ErrorReporter *reporter = &micro_reporter;
const tflite::Model *model;
// This pulls in all the operation implementations we need.
tflite::ops::micro::AllOpsResolver resolver;
tflite::SimpleTensorAllocator *tensor_allocator;
tflite::MicroInterpreter *interpreter;

extern "C" {

EMSCRIPTEN_KEEPALIVE
void load_model(uint8_t *model_bytes, const int tensor_arena_size) {
  // Map the model into a usable data structure. This doesn't involve any
  // copying or parsing, it's a very lightweight operation.
  model = tflite::GetModel(model_bytes);
  reporter->Report("Loaded model. Version: %d", model->version());

  uint8_t *tensor_arena = new uint8_t[tensor_arena_size];
  tensor_allocator =
      new tflite::SimpleTensorAllocator(tensor_arena, tensor_arena_size);

  // Build an interpreter to run the model with.
  interpreter =
      new tflite::MicroInterpreter(model, resolver, tensor_allocator, reporter);

  // Get information about the memory area to use for the model's input.
  TfLiteTensor *input = interpreter->input(0);

  reporter->Report("%d,%d,%d,%d", input->dims->data[0], input->dims->data[1],
                   input->dims->data[2], input->dims->data[3]);
  //   TF_LITE_MICRO_EXPECT_EQ(kTfLiteUInt8, input->type);
  // Copy a spectrogram created from a .wav audio file of someone saying "Yes",
  // into the memory area used for the input.
  // const uint8_t* features_data = g_yes_micro_f2e59fea_nohash_1_data;
  // Uncomment to test with different input, from a recording of "No".
  const uint8_t *features_data = g_no_micro_f9643d42_nohash_4_data;
  for (int i = 0; i < input->bytes; ++i) {
    input->data.uint8[i] = features_data[i];
  }

  // Run the model on this input and make sure it succeeds.
  TfLiteStatus invoke_status = interpreter->Invoke();
  if (invoke_status != kTfLiteOk) {
    reporter->Report("Invoke failed\n");
  }
  //   TF_LITE_MICRO_EXPECT_EQ(kTfLiteOk, invoke_status);

  // Get the output from the model, and make sure it's the expected size and
  // type.
  TfLiteTensor *output = interpreter->output(0);
  //   TF_LITE_MICRO_EXPECT_EQ(2, output->dims->size);
  //   TF_LITE_MICRO_EXPECT_EQ(1, output->dims->data[0]);
  //   TF_LITE_MICRO_EXPECT_EQ(4, output->dims->data[1]);
  //   TF_LITE_MICRO_EXPECT_EQ(kTfLiteUInt8, output->type);

  // There are four possible classes in the output, each with a score.
  const int kSilenceIndex = 0;
  const int kUnknownIndex = 1;
  const int kYesIndex = 2;
  const int kNoIndex = 3;

  // Make sure that the expected "Yes" score is higher than the other classes.
  uint8_t silence_score = output->data.uint8[kSilenceIndex];
  uint8_t unknown_score = output->data.uint8[kUnknownIndex];
  uint8_t yes_score = output->data.uint8[kYesIndex];
  uint8_t no_score = output->data.uint8[kNoIndex];
  reporter->Report("silence: %d\nunknown: %d\nyes: %d\nno: %d", silence_score,
                   unknown_score, yes_score, no_score);
  // TF_LITE_MICRO_EXPECT_GT(yes_score, silence_score);
  //   TF_LITE_MICRO_EXPECT_GT(yes_score, unknown_score);
  //   TF_LITE_MICRO_EXPECT_GT(yes_score, no_score);
}
}  // extern "C".
