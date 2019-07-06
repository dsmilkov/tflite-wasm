SRCS := \
tensorflow/lite/experimental/micro/micro_interpreter.cc \
tensorflow/lite/experimental/micro/simple_tensor_allocator.cc \
tensorflow/lite/experimental/micro/debug_log_numbers.cc \
tensorflow/lite/experimental/micro/debug_log.cc \
tensorflow/lite/experimental/micro/micro_mutable_op_resolver.cc \
tensorflow/lite/experimental/micro/micro_error_reporter.cc \
tensorflow/lite/experimental/micro/kernels/fully_connected.cc \
tensorflow/lite/experimental/micro/kernels/all_ops_resolver.cc \
tensorflow/lite/experimental/micro/kernels/elementwise.cc \
tensorflow/lite/experimental/micro/kernels/pooling.cc \
tensorflow/lite/experimental/micro/kernels/softmax.cc \
tensorflow/lite/experimental/micro/kernels/conv.cc \
tensorflow/lite/experimental/micro/kernels/depthwise_conv.cc \
tensorflow/lite/c/c_api_internal.c \
tensorflow/lite/core/api/error_reporter.cc \
tensorflow/lite/core/api/flatbuffer_conversions.cc \
tensorflow/lite/core/api/op_resolver.cc \
tensorflow/lite/kernels/kernel_util.cc \
tensorflow/lite/kernels/internal/quantization_util.cc \
tensorflow/lite/experimental/micro/wasm.cc \
tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/tiny_conv_micro_features_model_data.cc \
tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/no_micro_features_data.cc \
tensorflow/lite/experimental/micro/examples/micro_speech/micro_features/yes_micro_features_data.cc

OBJS := \
$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(SRCS)))

CXXFLAGS += -DNDEBUG -std=c++11 -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DTF_LITE_DISABLE_X86_NEON -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/kissfft
CCFLAGS += -DNDEBUG -DTF_LITE_STATIC_MEMORY -DTF_LITE_DISABLE_X86_NEON -DTF_LITE_DISABLE_X86_NEON -I. -I./third_party/gemmlowp -I./third_party/flatbuffers/include -I./third_party/kissfft

ifdef DEPLOY
	# Optimized.
	# -g0 Exclude all debug info.
	# -O3 Standard C/C++ optimization level.
	# --llvm-lto 3 LLVM link-time optimization.
	# --closure 1 Run closure compiler.
	# -fno-rtti -fno-exceptions Do not handle exceptions.
	# -s FILESYSTEM=0 Exclude file system support.
	# -s ENVIRONMENT=web Run only on the web.
	WASM_FLAGS := -g0 -O3 --llvm-lto 3 --closure 1 -fno-rtti -fno-exceptions -s FILESYSTEM=0 -s ENVIRONMENT=web
else
	# Development.
	# -g4 Include all debug info.
	# -O0 No optimization.
	# -s FILESYSTEM=0 Exclude file system support.
	WASM_FLAGS := -g4 -O0 -s FILESYSTEM=0
endif

%.o: %.cc
	$(CXX) $(CXXFLAGS) $(WASM_FLAGS) $(INCLUDES) -c $< -o $@

%.o: %.c
	$(CC) $(CCFLAGS) $(WASM_FLAGS) $(INCLUDES) -c $< -o $@

tflite: $(OBJS)
	$(CXX) $(CXXFLAGS) -o $(@).js $(OBJS) $(WASM_FLAGS)

clean:
	rm $(OBJS) tflite.*

all: tflite
