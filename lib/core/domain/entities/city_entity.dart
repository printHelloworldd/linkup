/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class CityEntity extends Equatable {
  final String name;

  const CityEntity({
    required this.name,
  });

  @override
  List<Object> get props {
    return [name];
  }
}
