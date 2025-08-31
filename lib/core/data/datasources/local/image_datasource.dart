/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// A data source responsible for image processing operations,
/// such as compression.
///
/// This implementation uses the [image] package to decode and
/// compress images.
class ImageDatasource {
  /// Compresses a raw image by decoding it and re-encoding as JPEG
  /// with 70% quality to reduce file size.
  ///
  /// Returns the compressed image as a [Uint8List], or `null` if
  /// decoding fails.
  Uint8List? compressImage(Uint8List rawImage) {
    try {
      img.Image? image = img.decodeImage(rawImage);

      if (image != null) {
        Uint8List compressed =
            Uint8List.fromList(img.encodeJpg(image, quality: 70));

        if (kDebugMode) {
          print('Image compressed!');
        }

        return compressed;
      }

      throw Exception("Failed to decode image");
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
