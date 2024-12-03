class WSRaceData {

  final String race_id;
  final String dates;
  final String logo;
  final String active;

  WSRaceData({required this.race_id,required this.dates,required this.logo,required this.active});

  factory WSRaceData.fromMap(Map<dynamic, dynamic> data) {
    return WSRaceData(
      race_id: data['race_id'] ?? '',
      dates: data['dates'] ?? '',
      logo: data['logo'] ?? '',
        active: data['active'] ?? ''
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'race_id': race_id,
      'dates': dates,
      'logo': logo,
      'active': active
    };
  }
}