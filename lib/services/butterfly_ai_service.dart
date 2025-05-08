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
          await Interpreter.fromAsset('assets/mobilenet_models_tflite__2025-05-04_02_12.tflite');
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  Future<Map<String, dynamic>> recognizeButterfly(File imageFile, int numberOfButterflySpecies) async {
    var inputDetails = interpreter.getInputTensor(0);
    var inputShape = inputDetails.shape;

    img.Image? imageDecoded = img.decodeImage(imageFile.readAsBytesSync())!;
    img.Image resizedImage = img.copyResize(imageDecoded,
        width: inputShape[1], height: inputShape[2]);

    Float32List inputBytes = Float32List(1 * inputShape[1] * inputShape[2] * 3);
    Uint8List imageBytes = resizedImage.getBytes();

    // Code om Uint8List type naar Float32List type te converteren
    for (int i = 0; i < imageBytes.length; i++) {
      inputBytes[i] = imageBytes[i].toDouble();
    }
    final input = inputBytes.reshape([1, inputShape[1], inputShape[2], 3]);

    // Output container
    final output = Float32List(1 * numberOfButterflySpecies).reshape([1, numberOfButterflySpecies]);

    // --- Hier vind inferentie plaats. De tijd hiervoor zal gemeten worden en getoond worden op de UI ---
    final stopwatch = Stopwatch()..start();
    interpreter.run(input, output);
    stopwatch.stop();
    final inferenceTimeMs = stopwatch.elapsedMilliseconds;
    devtools.log("Inference Time: ${inferenceTimeMs}ms");
    // --- End Measurement ---

// de output welke het model geeft is lijst met confidence scores voor alle vlindersoorten
    var volledigeOutputTensor = output[0];

    devtools.log(volledigeOutputTensor.toString());
//
    final predictionResult = volledigeOutputTensor as List<double>;

    // van de lijst met confidence scores wordt de hoogste score gepakt en
    // de vlindersoort tot welke deze toebehoort
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );

    int maxIndex = predictionResult.indexOf(maxElement);
    return {
      'confidence': maxElement,
      'positionModelOutput': maxIndex,
      'inferenceTimeMs': inferenceTimeMs,
    };
  }

  void closeInterpreter() {
    interpreter.close();
  }
}
