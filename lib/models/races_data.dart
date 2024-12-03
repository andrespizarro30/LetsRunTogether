class RacesData {

  final String race_id;
  final String dates;
  final String logo;

  RacesData({required this.race_id,required this.dates,required this.logo});

  factory RacesData.fromMap(Map<dynamic, dynamic> data, String id) {
    return RacesData(
      race_id: id,
      dates: data['Dates'] ?? '',
      logo: data['logo'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'race_id': race_id,
      'Dates': dates,
      'logo': logo
    };
  }
}