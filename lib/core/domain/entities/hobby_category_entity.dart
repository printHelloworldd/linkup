/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:equatable/equatable.dart';
import 'package:linkup/core/domain/entities/hobby_entity.dart';

class HobbyCategoryEntity extends Equatable {
  final String categoryName;
  final List<HobbyEntity> hobbiesList;

  const HobbyCategoryEntity({
    required this.categoryName,
    required this.hobbiesList,
  });

  @override
  List<Object?> get props {
    return [
      categoryName,
      hobbiesList,
    ];
  }
}
