
abstract class FirebaseUseEvent{

}

class GetRacesEvent extends FirebaseUseEvent {

}

class GetRaceCompetitorsEvent extends FirebaseUseEvent{

  String raceId="";

  GetRaceCompetitorsEvent(String raceId){
    this.raceId = raceId;
  }

}