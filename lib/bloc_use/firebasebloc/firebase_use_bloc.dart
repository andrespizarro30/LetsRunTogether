import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsruntogether/models/races_data.dart';

import '../../models/racer_data.dart';
import 'firebase_use_event.dart';
import 'firebase_use_state.dart';

class FirebaseUseBloc extends Bloc<FirebaseUseEvent, FirebaseUseState> {

  FirebaseUseBloc() : super(FirebaseUseInitial()) {
    on<FirebaseUseEvent>((event, emit) {
      if (event is GetRacesEvent) {
        getCurrentRaces();
      }else
      if(event is GetRaceCompetitorsEvent){
        getCurrentRaceRacers(event.raceId);
      }
    });
  }

  final List<RacesData> racesData = [];

  void getCurrentRaces() async{

    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('Races');

    emit(RacesDataLoadingState());
    try {
      // Fetch data once
      final DatabaseEvent snapshot = await _databaseRef.once();
    if (snapshot.snapshot.value != null) {
      Map<dynamic, dynamic> itemsMap = snapshot.snapshot.value as Map;
      itemsMap.forEach((key, value) {
        racesData.add(RacesData.fromMap(value, key));
      });
      emit(RacesDataLoadedState(racesData)); // Yield state with fetched items
    } else {
      emit(RacesDataErrorState('No data available'));
    }
    } catch (e) {
      emit(RacesDataErrorState('Error fetching data: $e'));
    }
  }

  void filterRacesData(String query){

    List<RacesData> filteredRaces = [];

    if(query.isNotEmpty){
      // Filter the races based on the race_id (case insensitive)
      filteredRaces = racesData.where((race) {
        return race.race_id.toLowerCase().contains(query);
      }).toList();
    }else{
      filteredRaces = racesData;
    }

    emit(RacesDataLoadedState(filteredRaces));

  }

  List<RacerData> racerData = [];

  void cleanRacerDataList(){
    racerData = [];
  }

  void getCurrentRaceRacers(String raceId) async{

    cleanRacerDataList();

    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('Races').child(raceId).child('Competitors');

    emit(RacesDataLoadingState());
    try {
      // Fetch data once
      final DatabaseEvent snapshot = await _databaseRef.once();
      if (snapshot.snapshot.value != null) {

        Map<dynamic, dynamic> itemsMap = snapshot.snapshot.value as Map;
        itemsMap.forEach((key, value) {
          bool exists = racerData.any((racer) => racer.racer_id == key);
          if(!exists){
            racerData.add(RacerData.fromMap(value, key));
          }
        });
        if(racerData.isNotEmpty){
          racerData.sort((a, b) => b.distanceRunned.compareTo(a.distanceRunned));
          emit(RacersDataLoadedState(racerData));
          listenRacersUpdates(raceId);
        }else{
          emit(RacersDataEmptyLoadedState());
        }
      } else {
        emit(RacesDataErrorState('No data available'));
      }
    } catch (e) {
      emit(RacesDataErrorState('Error fetching data: $e'));
    }
  }

  void listenRacersUpdates(String raceId) async{

    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('Races').child(raceId).child('Competitors');

    _databaseRef.onChildAdded.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> itemsMap = snapshot.value as Map;

        bool exists = racerData.any((racer) => racer.racer_id == snapshot.key!);
        if(!exists){
          racerData.add(RacerData.fromMap(itemsMap, snapshot.key!));
        }

        if(racerData.isNotEmpty){
          racerData.sort((a, b) => b.distanceRunned.compareTo(a.distanceRunned));
          emit(RacersDataLoadedState(racerData));
        }else{
          emit(RacersDataEmptyLoadedState());
        }
      }
    });

    _databaseRef.onChildChanged.listen((DatabaseEvent event) {
      final snapshot = event.snapshot;

      if (snapshot.value != null) {
        Map<dynamic, dynamic> itemsMap = snapshot.value as Map;

        var racer = racerData.firstWhere((racer) => racer.racer_id == snapshot.key!);
        if (racer != null) {
          racerData.remove(racer);
        }

        racerData.add(RacerData.fromMap(itemsMap, snapshot.key!));

        if(racerData.isNotEmpty){
          racerData.sort((a, b) => b.distanceRunned.compareTo(a.distanceRunned));
          emit(RacersDataLoadedState(racerData));
        }else{
          emit(RacersDataEmptyLoadedState());
        }
      }
    });

  }

  void updateRunnerDistanceandTime(String raceId,double distance, String time, Position location){

  }

}
