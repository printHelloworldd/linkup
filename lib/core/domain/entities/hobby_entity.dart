/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

import 'package:equatable/equatable.dart';

class HobbyEntity extends Equatable {
  final String hobbyName;
  final String categoryName;
  // final List<String>? iconsList;
  final String? icon;

  const HobbyEntity({
    required this.hobbyName,
    required this.categoryName,
    // this.iconsList,
    this.icon,
  });

  @override
  List<Object?> get props {
    return [
      hobbyName,
      categoryName,
      // iconsList,
      icon,
    ];
  }
}
