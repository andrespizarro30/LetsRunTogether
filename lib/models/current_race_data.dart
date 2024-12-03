class CurrentRaceData {

  final String racer_id;
  final int distanceRunned;
  final double latitude;
  final double longitude;
  final double speed;
  final String timeRunned;
  final String name;

  CurrentRaceData(
      {required this.racer_id,
        required this.distanceRunned,
        required this.latitude,
        required this.longitude,
        required this.speed,
        required this.timeRunned,
        required this.name
      });

  factory CurrentRaceData.fromMap(Map<dynamic, dynamic> data, String id) {
    return CurrentRaceData(
        racer_id: id,
        distanceRunned: int.parse(data['DistanceRunned'].toString()),
        latitude: double.parse(data['Location']['latitude'].toString()),
        longitude: double.parse(data['Location']['longitude'].toString()),
        speed: double.parse(data['Speed'].toString()),
        timeRunned: data['TimeRunned'] ?? '',
        name: data['name'] ?? ''
    );
  }

  factory CurrentRaceData.fromMap2(Map<dynamic, dynamic> data, String id) {
    return CurrentRaceData(
        racer_id: data['competitor_id'].toString(),
        distanceRunned: int.parse(data['distance_runned'].toString()),
        latitude: double.parse(data['latitude'].toString()),
        longitude: double.parse(data['longitude'].toString()),
        speed: double.parse(data['speed'].toString()),
        timeRunned: data['time_runned'] ?? '',
        name: data['name'] ?? ''
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
      'name': name ?? ''
    };
  }

}