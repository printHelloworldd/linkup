import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';

class HobbySelectionCubit extends Cubit<Set<HobbyEntity>> {
  HobbySelectionCubit() : super({});

  void toggleHobby(HobbyEntity hobby) {
    final newSelectedHobbies = Set<HobbyEntity>.from(state);
    if (newSelectedHobbies.contains(hobby)) {
      newSelectedHobbies.remove(hobby);
    } else {
      newSelectedHobbies.add(hobby);
    }
    emit(newSelectedHobbies);
  }

  void setInitialHobbies(Set<HobbyEntity> hobbies) {
    emit(hobbies);
  }
}
