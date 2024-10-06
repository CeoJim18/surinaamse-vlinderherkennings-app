import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:developer' as devtools;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
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

  Future<void> _tfLteInit() async {
    try {
      InterpreterOptions().useNnApiForAndroid = true;
      interpreter = await Interpreter.fromAsset('assets/model1(new).tflite',
          options: InterpreterOptions());
    } catch (e) {
      devtools.log("Error loading model: $e");
    }
  }

  pickImageGallery() async {
    var inputDetails = interpreter.getInputTensor(0);
    var inputShape =
        inputDetails.shape; // Input shape [1, height, width, channels]

    devtools.log(inputShape.toString());
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image == null) return;

    var imageFile = File(image.path);

    setState(() {
      filePath = imageFile;
    });

// IMAGE PREPROCESSING
    // img.Image imageDecoded = img.decodeImage(imageFile.readAsBytesSync())!;

    // img.Image resizedImage = img.copyResize(imageDecoded,
    //     width: inputShape[1], height: inputShape[2]);

    // var inputData = imageToByteListFloat32(
    //     resizedImage.getBytes(), resizedImage.width, resizedImage.height);

    // volgens https://medium.com/geekculture/bring-your-image-classification-model-to-life-with-flutter-5148efbf3647:

    img.Image? imageDecoded = img.decodeImage(imageFile.readAsBytesSync())!;

    img.Image resizedImage = img.copyResize(imageDecoded,
        width: inputShape[1], height: inputShape[2]);

    Float32List inputBytes = Float32List(1 * inputShape[1] * inputShape[2] * 3);
    int pixelIndex = 0;
    Uint8List imageBytes =
        resizedImage.getBytes(); // Get raw bytes of the image

    // Loop over every pixel
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        // Get the pixel's offset (each pixel is represented by 4 bytes: RGBA)
        int pixelOffset = (y * resizedImage.width + x) * 4;

        // Extract RGB values from the pixel
        int r = imageBytes[pixelOffset]; // Red channel
        int g = imageBytes[pixelOffset + 1]; // Green channel
        int b = imageBytes[pixelOffset + 2]; // Blue channel

        // Normalize the RGB values to the range [-1, 1]
        inputBytes[pixelIndex++] = r / 127.5 - 1.0;
        inputBytes[pixelIndex++] = g / 127.5 - 1.0;
        inputBytes[pixelIndex++] = b / 127.5 - 1.0;
      }
    }

// ----------------------------------------------------------
// Add batch dimension if necessary (check your model's input shape)
    // if (inputShape[0] == 1) {
    // If batch size is 1
    // inputData = inputData;
    // }
    // var output = List.filled(1 * 3, 0);
// ----------------------------------------------------------
    final input = inputBytes.reshape([1, 320, 320, 3]);

    // Output container
    final output = Float32List(1 * 3).reshape([1, 3]);
    interpreter.run(input, output);

    // var finaloutPut = output;

    // devtools.log(finaloutPut.toString());
    var volledigeOutputTensor = output[0];

    final predictionResult = output[0] as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );

    devtools.log(predictionResult.indexOf(maxElement).toString());
    // var outputTensor = interpreter.getOutputTensor(0);

//     // Get the buffer associated with the output tensor
//     Uint8List buffer = outputTensor.data;

// // Create a Float32List view of the buffer
//     Uint8List outputData = buffer;

// Find the class with the highest probability
    // int maxIndex = 0;
    // int maxValue = outputData[0];
    // for (int i = 1; i < outputData.length; i++) {
    //   if (outputData[i] > maxValue) {
    //     maxValue = outputData[i];
    //     maxIndex = i;
    //   }
    // }

    setState(() {
      // confidence = maxValue as double;
      // label = "Class $maxIndex"; // Assuming your labels are just class numbers
    });
  }

  List<List<List<List<double>>>> imageToByteListFloat32(
      Uint8List imageBytes, int width, int height) {
    var convertedBytes = Float32List(1 * width * height * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int i = 0; i < width * height; i++) {
      int pixel = imageBytes[i * 4]; // Assuming 4 channels (RGBA)

      // Extract color components using bitwise operations
      int red = (pixel >> 16) & 0xFF;
      int green = (pixel >> 8) & 0xFF;
      int blue = pixel & 0xFF;

      buffer[pixelIndex++] = (red - 127.5) / 127.5;
      buffer[pixelIndex++] = (green - 127.5) / 127.5;
      buffer[pixelIndex++] = (blue - 127.5) / 127.5;
    }
    return [
      [
        [convertedBytes.buffer.asFloat32List()]
      ]
    ];
  }

  // Future<List<List<double>>> runModelOnImage(
  //     List<List<List<List<double>>>> input) async {
  //   // Flatten the input list
  //   List<double> flattenedInput =
  //       input.expand((i) => i).expand((i) => i).expand((i) => i).toList();

  //   // Create a Float32List from the flattened input
  //   Float32List inputFloat32List = Float32List.fromList(flattenedInput);

  //   // Create a Tensor from the Float32List
  //   var inputTensor = Tensor(interpreter, 0); // Assuming input is at index 0
  //   inputTensor.copyFromBuffer(inputFloat32List.buffer);

  //   var outputTensor =
  //       TensorBuffer.createFixedSize(<int>[1, 1001], TfLiteType.float32);

  //   interpreter.run(inputTensor, outputTensor);

  //   return outputTensor.getDoubleList().reshape([1, 1001]);
  // }

//   pickImageCamera() async {
//     final ImagePicker picker = ImagePicker();
// // Pick an image.
//     final XFile? image = await picker.pickImage(source: ImageSource.camera);

//     if (image == null) return;

//     var imageMap = File(image.path);

//     setState(() {
//       filePath = imageMap;
//     });

//     // var recognitions = await Tflite.runModelOnImage(
//     //     path: image.path, // required
//     //     imageMean: 0.0, // defaults to 117.0
//     //     imageStd: 255.0, // defaults to 1.0
//     //     numResults: 2, // defaults to 5
//     //     threshold: 0.2, // defaults to 0.1
//     //     asynch: true // defaults to true
//     //     );

//     if (recognitions == null) {
//       devtools.log("recognitions is Null");
//       return;
//     }
//     devtools.log(recognitions.toString());
//     setState(() {
//       confidence = (recognitions[0]['confidence'] * 100);
//       label = recognitions[0]['label'].toString();
//     });
//   }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    interpreter.close();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tfLteInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mango Dresses Detection"),
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
                                "The Accuracy is ${confidence.toStringAsFixed(0)}%",
                                style: const TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(
                                height: 12,
                              ),
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
