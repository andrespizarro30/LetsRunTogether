
import 'package:equatable/equatable.dart';
import 'package:letsruntogether/models/racer_data.dart';
import '../../models/races_data.dart';

abstract class FirebaseUseState{}

final class FirebaseUseInitial extends FirebaseUseState {}

class RacesDataInitialState extends FirebaseUseState {}

class RacesDataLoadingState extends FirebaseUseState {}

//RACES DATA
class RacesDataLoadedState extends FirebaseUseState {
  final List<RacesData> items;
  RacesDataLoadedState(this.items);
}

class RacesDataErrorState extends FirebaseUseState {
  final String message;
  RacesDataErrorState(this.message);
}

//RACERS DATA
class RacersDataLoadedState extends FirebaseUseState{
  final List<RacerData> items;
  RacersDataLoadedState(this.items);
}

class RacersDataEmptyLoadedState extends FirebaseUseState{
  RacersDataEmptyLoadedState();
}
