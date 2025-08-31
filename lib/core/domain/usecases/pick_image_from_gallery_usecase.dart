/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'dart:typed_data';

import 'package:linkup/core/domain/repository/image_picker_repository.dart';

class PickImageFromGalleryUsecase {
  final ImagePickerRepository imagePickerRepository;

  PickImageFromGalleryUsecase(this.imagePickerRepository);

  Future<Uint8List?> call() async {
    return await imagePickerRepository.pickImageFromGallery();
  }
}
