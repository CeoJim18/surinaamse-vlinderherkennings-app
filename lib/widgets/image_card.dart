import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../screens/butterfly_information_page.dart';

class ImageCard extends StatelessWidget {
  final String label;
  final double confidence;
  final File? filePath;
  final bool isRecognitionLoading;

  const ImageCard({
    super.key,
    required this.label,
    required this.confidence,
    required this.filePath,
    required this.isRecognitionLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                  image: (filePath == null && isRecognitionLoading)
                      ? null
                      : (filePath == null)
                          ? const DecorationImage(
                              image: AssetImage('assets/upload.jpg'),
                            )
                          : DecorationImage(
                              image: FileImage(filePath!),
                              fit: BoxFit.cover,
                            ),
                ),
                child: isRecognitionLoading
                    ? LoadingAnimationWidget.flickr(
                        leftDotColor: const Color(0xFF0063DC),
                        rightDotColor: const Color(0xFFFF0084),
                        size: 100)
                    : null,
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
                      "Probability: ${confidence.toStringAsFixed(2)}%",
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
                                      ButterflyInformationPage(
                                          vlinderSoort: label)));
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
