import 'package:flutter/foundation.dart';

class LevelModel {
    final int id;
    final String name; // `Name` dans TS

    LevelModel({required this.id, required this.name});

    factory LevelModel.fromJson(Map<String, dynamic> json) {
      return LevelModel(id: json['id'], name: json['Name']);
    }
}

class SpecialityModel {
    final int id;
    final String specialityName;

    SpecialityModel({required this.id, required this.specialityName});

    factory SpecialityModel.fromJson(Map<String, dynamic> json) {
      return SpecialityModel(id: json['id'], specialityName: json['specialityName']);
    }
}