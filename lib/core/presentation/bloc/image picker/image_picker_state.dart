part of 'image_picker_bloc.dart';

sealed class ImagePickerState extends Equatable {
  const ImagePickerState();

  @override
  List<Object?> get props => [];
}

final class ImagePickerInitial extends ImagePickerState {}

class SettingImageFromGallery extends ImagePickerState {}

class PickedImageFromGallery extends ImagePickerState {
  final Uint8List? imageBytes;

  const PickedImageFromGallery({
    required this.imageBytes,
  });

  @override
  List<Object?> get props => [imageBytes];
}
