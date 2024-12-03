import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RacerData {

  final String racer_id;
  final int distanceRunned;
  final double latitude;
  final double longitude;
  final double speed;
  final String timeRunned;
  final String name;
  int position;

  RacerData(
      {required this.racer_id,
        required this.distanceRunned,
        required this.latitude,
        required this.longitude,
        required this.speed,
        required this.timeRunned,
        required this.name,
        required this.position
    });

  factory RacerData.fromMap(Map<dynamic, dynamic> data, String id) {
    return RacerData(
      racer_id: id,
      distanceRunned: int.parse(data['RaceData']['DistanceRunned'].toString()),
      latitude: double.parse(data['RaceData']['Location']['latitude'].toString()),
      longitude: double.parse(data['RaceData']['Location']['longitude'].toString()),
      speed: double.parse(data['RaceData']['Speed'].toString()),
      timeRunned: data['RaceData']['TimeRunned'] ?? '',
      name: data['RaceData']['name'] ?? '',
      position: 0
    );
  }

  factory RacerData.fromMap2(Map<dynamic, dynamic> data) {
    return RacerData(
        racer_id: data['competitor_id'].toString(),
        distanceRunned: int.parse(data['distance_runned'].toString()),
        latitude: double.parse(data['latitude'].toString()),
        longitude: double.parse(data['longitude'].toString()),
        speed: double.parse(data['speed'].toString()),
        timeRunned: data['time_runned'] ?? '',
        name: data['name'] ?? '',
        position: 0
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'racer_id': racer_id ?? '',
      'distanceRunned': distanceRunned ?? 0.0,
      'latitude': latitude ?? 0.0,
      'longitude': longitude ?? 0.0,
      'speed': speed ?? 0.0,
      'timeRunned': timeRunned ?? '',
      'name': name ?? '',
      'position': position
    };
  }

}