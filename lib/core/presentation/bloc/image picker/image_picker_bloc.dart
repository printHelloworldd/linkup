import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/usecases/pick_image_from_gallery_usecase.dart';

part 'image_picker_event.dart';
part 'image_picker_state.dart';

class ImagePickerBloc extends Bloc<ImagePickerEvent, ImagePickerState> {
  final PickImageFromGalleryUsecase pickImageFromGalleryUsecase;

  ImagePickerBloc({
    required this.pickImageFromGalleryUsecase,
  }) : super(ImagePickerInitial()) {
    on<PickImageFromGallery>((event, emit) async {
      try {
        emit(SettingImageFromGallery());
        final imageBytes = await pickImageFromGalleryUsecase();
        emit(PickedImageFromGallery(imageBytes: imageBytes));
      } catch (e) {
        print("Failed to pick image from gallery!");
      }
    });
  }
}
