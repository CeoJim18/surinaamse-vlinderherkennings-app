import 'dart:developer' as devtools;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myapp/services/butterfly_ai_service.dart';
import 'package:myapp/services/database_service.dart';
import 'package:myapp/widgets/action_button.dart';
import 'package:myapp/widgets/image_cart.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  late Interpreter interpreter;
  final DatabaseService _databaseService = DatabaseService.instance;
  final ButterflyAIService butterflyAIService = ButterflyAIService();

  // List<String> butterflySpecies = [
  //   'Heraclides thoas',
  //   'Heliopetes arsalte',
  //   'Heliconius antiochus'
  // ];

  // Future<void> _tfLteInit() async {
  //   try {
  //     // InterpreterOptions().useNnApiForAndroid = true;
  //     interpreter =
  //         await Interpreter.fromAsset('assets/__2024-10-07_01_46.tflite');
  //   } catch (e) {
  //     devtools.log("Error loading model: $e");
  //   }
  // }

  pickImageGallery() async {
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    final result = await butterflyAIService.recognizeButterfly(imageFile);
    final indexModelOutput = result[
        'positionModelOutput']; // class number in classifier layer van model
    final positionModelOutput = indexModelOutput +
        1; // class nummer + 1, om te voorkomen dat er een 0 erin voorkomt
    final maxElement = result['confidence'];
    final speciesData =
        await _databaseService.getButterflySpeciesName(positionModelOutput);

    String speciesName = speciesData!['species_name'];

    devtools.log(speciesName);
    devtools.log(maxElement.toString());

    setState(() {
      confidence = maxElement * 100;
      label = speciesName;
    });
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
              ),
              const SizedBox(
                height: 8,
              ),
              ActionButton(
                  onPressedFunction: pickImageGallery,
                  buttonText: "Pick from gallery"),
              const SizedBox(
                height: 8,
              ),
              ActionButton(onPressedFunction: () {}, buttonText: "buttonText"),
            ],
          ),
        ),
      ),
    );
  }
}
