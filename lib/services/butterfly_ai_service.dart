import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter/tflite_flutter_method_channel.dart';
import 'dart:developer' as devtools;

import 'package:tflite_flutter/tflite_flutter_platform_interface.dart';

class ButterflyAIService {
  late Interpreter interpreter;

  Future<void> initInterpreter() async {
    try {
      interpreter =
          await Interpreter.fromAsset('assets/__2025-04-30_21_39.tflite');
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>> recognizeButterfly(File imageFile, int numberOfImages) async {
    var inputDetails = interpreter.getInputTensor(0);
    var inputShape = inputDetails.shape;

    img.Image? imageDecoded = img.decodeImage(imageFile.readAsBytesSync())!;
    img.Image resizedImage = img.copyResize(imageDecoded,
        width: inputShape[1], height: inputShape[2]);

    Float32List inputBytes = Float32List(1 * inputShape[1] * inputShape[2] * 3);
    int pixelIndex = 0;
    Uint8List imageBytes = resizedImage.getBytes();

    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        int pixelOffset = (y * resizedImage.width + x) * 3;

        int r = imageBytes[pixelOffset]; // Red channel
        int g = imageBytes[pixelOffset + 1]; // Green channel
        int b = imageBytes[pixelOffset + 2]; // Blue channel

        // Normalize the RGB values
        inputBytes[pixelIndex++] = r.toDouble(); // R
        inputBytes[pixelIndex++] = g.toDouble(); // G
        inputBytes[pixelIndex++] = b.toDouble(); // B
      }
    }
    final input = inputBytes.reshape([1, inputShape[1], inputShape[2], 3]);

    // Output container
    final output = Float32List(1 * numberOfImages).reshape([1, numberOfImages]);
    interpreter.run(input, output);
    var volledigeOutputTensor = output[0];

    devtools.log(volledigeOutputTensor.toString());

    final predictionResult = volledigeOutputTensor as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );

    int maxIndex = predictionResult.indexOf(maxElement);
    return {
      'confidence': maxElement,
      'positionModelOutput': maxIndex,
    };
  }

  void closeInterpreter() {
    interpreter.close();
  }
}
