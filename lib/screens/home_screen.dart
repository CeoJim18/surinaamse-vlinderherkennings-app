import 'dart:developer' as devtools;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:myapp/services/butterfly_ai_service.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/image_card.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import '../constants/butterfly_species.dart';
import '../services/image_picker_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  bool isRecognitionLoading = false;
  int? inferenceTimeMs;
  late Interpreter interpreter;
  final ButterflyAIService butterflyAIService = ButterflyAIService();
  final ImagePickerService imagePickerService = ImagePickerService();

  Future<void> _processImageAndRecognize(File? imageFile) async {
    if (imageFile == null) {
      // Handle case where user cancelled picking/taking image
      setState(() {
        isRecognitionLoading = false; // Ensure loading stops if cancelled early
      });
      return;
    }

    setState(() {
      filePath = null; // Clear previous image display while processing new one
      label = '';
      confidence = 0.0;
      inferenceTimeMs = null;
      isRecognitionLoading = true;
    });

    try {
      // Use the length from the imported constant list
      final result = await butterflyAIService.recognizeButterfly(
          imageFile, butterflySpecies.length);
      final indexModelOutput = result['positionModelOutput'];
      final maxElement = result['confidence'];
      final timeMs = result['inferenceTimeMs'];

      // Ensure index is within bounds using the constant list
      if (indexModelOutput >= 0 && indexModelOutput < butterflySpecies.length) {
        String speciesName = butterflySpecies[indexModelOutput];
        devtools.log('Recognized: $speciesName');
        devtools.log('Confidence: ${maxElement.toString()}');

        setState(() {
          filePath = imageFile;
          confidence = maxElement * 100;
          label = speciesName;
          inferenceTimeMs = timeMs;
        });
      } else {
        devtools
            .log('Error: Invalid index from model output: $indexModelOutput');
        setState(() {
          filePath = imageFile; // Show the image even if recognition failed
          label = 'Recognition Error';
          confidence = 0.0;
          inferenceTimeMs = timeMs;
        });
      }
    } catch (e) {
      devtools.log('Error during recognition: $e');
      setState(() {
        filePath = imageFile; // Show the image even on error
        label = 'Error';
        confidence = 0.0;
        inferenceTimeMs = null;
      });
    } finally {
      setState(() {
        isRecognitionLoading = false;
      });
    }
  }

  // Updated method using the service and helper
  pickImageGalleryAndRecognize() async {
    File? imageFile = await imagePickerService.pickImageFromGallery();
    await _processImageAndRecognize(imageFile);
  }

  // Updated method using the service and helper
  takePictureAndRecognize() async {
    File? imageFile = await imagePickerService.takePictureWithCamera();
    await _processImageAndRecognize(imageFile);
  }

  @override
  void dispose() {
    butterflyAIService.closeInterpreter();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    butterflyAIService.initInterpreter();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Butterfly Recognition App"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 12,
              ),
              ImageCard(
                label: label,
                confidence: confidence,
                filePath: filePath,
                isRecognitionLoading: isRecognitionLoading,
                inferenceTimeMs: inferenceTimeMs,
              ),
              const SizedBox(
                height: 8,
              ),
              ActionButton(
                  onPressedFunction: pickImageGalleryAndRecognize,
                  buttonText: "Pick from gallery"),
              const SizedBox(
                height: 8,
              ),
              ActionButton(
                  onPressedFunction: takePictureAndRecognize,
                  buttonText: "Take a picture"),
            ],
          ),
        ),
      ),
    );
  }
}
