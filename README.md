# TFLite Wasm Exploration

### Requirements

- Emscripten

### Building the wasm and js files

- `emmake make`: produces an unoptimized (with debug info) `tflite.js` and `tflite.wasm` for development.
- `emmake make DEPLOY=1` produces optimized (for size and speed) `tflite.js` and `tflite.wasm` for deployment.
- `emmake make clean`: removes the generated output.
