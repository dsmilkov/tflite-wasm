SRCS := \
tensorflow/lite/experimental/micro/micro_interpreter.cc tensorflow/lite/experimental/micro/simple_tensor_allocator.cc tensorflow/lite/experimental/micro/debug_log_numbers.cc tensorflow/lite/experimental/micro/debug_log.cc tensorflow/lite/experimental/micro/micro_mutable_op_resolver.cc tensorflow/lite/experimental/micro/micro_error_reporter.cc tensorflow/lite/experimental/micro/kernels/fully_connected.cc tensorflow/lite/experimental/micro/kernels/all_ops_resolver.cc tensorflow/lite/experimental/micro/kernels/elementwise.cc tensorflow/lite/experimental/micro/kernels/pooling.cc tensorflow/lite/experimental/micro/kernels/softmax.cc tensorflow/lite/experimental/micro/kernels/conv.cc tensorflow/lite/experimental/micro/kernels/depthwise_conv.cc tensorflow/lite/c/c_api_internal.c tensorflow/lite/core/api/error_reporter.cc tensorflow/lite/core/api/flatbuffer_conversions.cc tensorflow/lite/core/api/op_resolver.cc tensorflow/lite/kernels/kernel_util.cc tensorflow/lite/kernels/internal/quantization_util.cc  tensorflow/lite/experimental/micro/examples/micro_speech/micro_speech_test.cc tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/tiny_conv_micro_features_model_data.cc tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/no_micro_features_data.cc tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/yes_micro_features_data.cc

OBJS := \
$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(SRCS)))

CXXFLAGS += -O3 -DNDEBUG -std=c++11 -g -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DTF_LITE_DISABLE_X86_NEON -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/kissfft
CCFLAGS +=  -DNDEBUG -g -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DTF_LITE_DISABLE_X86_NEON -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/kissfft

LDFLAGS +=  -lm -framework Foundation -framework AudioToolbox

%.o: %.cc
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@

%.o: %.c
	$(CC) $(CCFLAGS) $(INCLUDES) -c $< -o $@

micro_speech_test : $(OBJS)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJS) $(LDFLAGS)

all: micro_speech_test
