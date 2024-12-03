import 'package:geolocator/geolocator.dart';

abstract class GeolocationEvent {}

class StartLocationTracking extends GeolocationEvent {}

class StopLocationTracking extends GeolocationEvent {}

class ResumeLocationTracking extends GeolocationEvent {}

class SetRaceId extends GeolocationEvent{

  String raceId="";

  SetRaceId(String raceId){
    this.raceId = raceId;
  }

}

class UpdateRaceCompetitorsData extends GeolocationEvent{

  String time="00:00:00";

  UpdateRaceCompetitorsData(String time){
    this.time = time;
  }

}

class ApiCallingEvent extends GeolocationEvent{

}