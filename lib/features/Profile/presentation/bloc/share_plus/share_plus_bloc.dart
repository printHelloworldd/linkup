// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:share_plus/share_plus.dart';
import 'package:linkup/core/domain/entities/user/user_entity.dart';

import 'package:linkup/features/Profile/domain/usecases/share_profile_usecase.dart';

part 'share_plus_event.dart';
part 'share_plus_state.dart';

class SharePlusBloc extends Bloc<SharePlusEvent, SharePlusState> {
  final ShareProfileUsecase shareProfileUsecase;

  SharePlusBloc({
    required this.shareProfileUsecase,
  }) : super(SharePlusInitial()) {
    on<ShareProfileEvent>((event, emit) async {
      try {
        final result = await shareProfileUsecase(event.user);

        if (result.status == ShareResultStatus.success) {
          emit(SharingProfileSuccess());
        } else if (result.status == ShareResultStatus.dismissed) {
          emit(SharingProfileDismissed());
        }
      } catch (e) {
        emit(SharingProfileFailure());
      }
    });
  }
}
