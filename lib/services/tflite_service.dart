// Platform-aware export: use the native FFI implementation on mobile/desktop
// and a lightweight web stub when compiling for the browser to avoid FFI
// compilation errors (web builds don't support `dart:ffi` or `tflite_flutter`).
export 'tflite_service_io.dart'
    if (dart.library.html) 'tflite_service_web.dart';
