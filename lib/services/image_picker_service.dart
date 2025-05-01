// lib/services/image_picker_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  Future<File?> pickImageFromGallery() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null) return null;
    return File(image.path);
  }

  Future<File?> takePictureWithCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85, // Consistent quality/size
      maxWidth: 512,
      maxHeight: 512,
    );

    if (image == null) return null;
    return File(image.path);
  }
}