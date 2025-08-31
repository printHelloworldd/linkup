/*
This file is part of LinkUp,
an open-source application for secure communication.

For license and copyright information please see:
https://github.com/printHelloworldd/linkup/blob/main/LEGAL.md
*/

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

class CountryEntity extends Equatable {
  final String name;
  final String iso2;
  final String? native;
  final String? emoji;

  const CountryEntity({
    required this.name,
    required this.iso2,
    this.native,
    this.emoji,
  });

  @override
  List<Object?> get props {
    return [
      name,
      iso2,
      native,
      emoji,
    ];
  }
}
