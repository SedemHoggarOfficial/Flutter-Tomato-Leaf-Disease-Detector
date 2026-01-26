import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Image preprocessing utilities for ML model input
/// These functions are designed to work inside isolates
class ImageHelper {
  /// Resize image to target dimensions
  static img.Image resizeImage(img.Image image, int targetSize) {
    return img.copyResize(image, width: targetSize, height: targetSize);
  }

  /// Convert image to Float32List normalized to [0, 1]
  static Float32List imageToFloat32List(img.Image image, int inputSize) {
    final Float32List buffer = Float32List(inputSize * inputSize * 3);
    int index = 0;

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        final pixel = image.getPixel(x, y);
        buffer[index++] = pixel.r / 255.0;
        buffer[index++] = pixel.g / 255.0;
        buffer[index++] = pixel.b / 255.0;
      }
    }
    return buffer;
  }

  /// Convert flat Float32List to 4D nested list for TFLite model
  static List<List<List<List<double>>>> bufferTo4DList(
    Float32List buffer,
    int inputSize,
  ) {
    int index = 0;
    List<List<List<List<double>>>> result = List.generate(
      1,
      (_) => List.generate(
        inputSize,
        (_) => List.generate(inputSize, (_) => List.filled(3, 0.0)),
      ),
    );

    for (int y = 0; y < inputSize; y++) {
      for (int x = 0; x < inputSize; x++) {
        result[0][y][x][0] = buffer[index++];
        result[0][y][x][1] = buffer[index++];
        result[0][y][x][2] = buffer[index++];
      }
    }
    return result;
  }
}

/// Data class for passing preprocessing parameters to isolate
class PreprocessParams {
  final Uint8List imageBytes;
  final int inputSize;

  PreprocessParams({
    required this.imageBytes,
    required this.inputSize,
  });
}

/// Result from preprocessing isolate
class PreprocessResult {
  final List<List<List<List<double>>>> input4D;

  PreprocessResult({required this.input4D});
}

/// Preprocessing function to run in isolate
PreprocessResult preprocessImageIsolate(PreprocessParams params) {
  final image = img.decodeImage(params.imageBytes);
  if (image == null) {
    throw Exception('Failed to decode image');
  }

  final resized = ImageHelper.resizeImage(image, params.inputSize);
  final buffer = ImageHelper.imageToFloat32List(resized, params.inputSize);
  final input4D = ImageHelper.bufferTo4DList(buffer, params.inputSize);

  return PreprocessResult(input4D: input4D);
}
