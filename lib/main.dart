import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:myapp/screens/information_page.dart';
import 'package:myapp/services/database_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? filePath;
  String label = '';
  double confidence = 0.0;
  late Interpreter interpreter;
  final DatabaseService _databaseService = DatabaseService.instance;

  // List<String> butterflySpecies = [
  //   'Heraclides thoas',
  //   'Heliopetes arsalte',
  //   'Heliconius antiochus'
  // ];

  Future<void> _tfLteInit() async {
    try {
      // InterpreterOptions().useNnApiForAndroid = true;
      interpreter =
          await Interpreter.fromAsset('assets/__2024-10-07_01_46.tflite');
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  pickImageGallery() async {
    var inputDetails = interpreter.getInputTensor(0);

    var inputShape = inputDetails.shape;

    devtools.log(inputShape.toString());
    final ImagePicker picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

    // volgens https://medium.com/geekculture/bring-your-image-classification-model-to-life-with-flutter-5148efbf3647:

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
    final output = Float32List(1 * 3).reshape([1, 3]);
    interpreter.run(input, output);
    var volledigeOutputTensor = output[0];

    devtools.log(volledigeOutputTensor.toString());

    final predictionResult = volledigeOutputTensor as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );

    int maxIndex = predictionResult.indexOf(maxElement);
int positionModelOutput = maxIndex + 1;
    final speciesData = await _databaseService.getButterflySpeciesName(positionModelOutput + 1);

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
    super.dispose();
    interpreter.close();
  }

  @override
  void initState() {
    super.initState();
    _tfLteInit();
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
              Card(
                elevation: 20,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: 300,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 18,
                        ),
                        Container(
                          height: 280,
                          width: 280,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            image: const DecorationImage(
                              image: AssetImage('assets/upload.jpg'),
                            ),
                          ),
                          child: filePath == null
                              ? const Text('')
                              : Image.file(
                                  filePath!,
                                  fit: BoxFit.fill,
                                ),
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                label,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                "The Accuracy is ${confidence.toStringAsFixed(2)}%",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                              CupertinoButton(
                                  child: label.isNotEmpty
                                      ? const Text('Learn more',
                                          style: TextStyle(
                                              color: Colors.deepPurple,
                                              fontWeight: FontWeight.bold))
                                      : const Text(''),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                            builder: (context) =>
                                                InformationPage(
                                                    vlinderSoort: label)));
                                  })
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Take a Photo",
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              ElevatedButton(
                onPressed: () {
                  pickImageGallery();
                },
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                    foregroundColor: Colors.black),
                child: const Text(
                  "Pick from gallery",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
