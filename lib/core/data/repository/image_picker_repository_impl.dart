/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:typed_data';

import 'package:linkup/core/data/datasources/local/image_datasource.dart';
import 'package:linkup/core/data/datasources/local/image_picker_datasource.dart';
import 'package:linkup/core/domain/repository/image_picker_repository.dart';

class ImagePickerRepositoryImpl implements ImagePickerRepository {
  final ImagePickerDatasource imagePickerDatasource;
  final ImageDatasource imageDatasource;

  ImagePickerRepositoryImpl(this.imagePickerDatasource, this.imageDatasource);

  @override
  Future<Uint8List?> pickImageFromGallery() async {
    final rawImage = await imagePickerDatasource.pickImageFromGallery();
    if (rawImage != null) {
      final compressedImage = imageDatasource.compressImage(rawImage);

      return compressedImage;
    } else {
      return null;
    }
  }
}
