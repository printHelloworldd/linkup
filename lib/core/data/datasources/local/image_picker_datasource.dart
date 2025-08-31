/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerDatasource {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImageFromGallery() async {
    try {
      final XFile? returnedImage =
          await _picker.pickImage(source: ImageSource.gallery);

      if (returnedImage == null) return null;
      return await returnedImage.readAsBytes();
    } catch (e) {
      if (kDebugMode) {
        print("Failed to pick an image: $e");
      }

      throw Exception(e.toString());
    }
  }
}
