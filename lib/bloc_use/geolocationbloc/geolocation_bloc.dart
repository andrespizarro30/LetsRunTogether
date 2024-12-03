import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';


import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsruntogether/common/android_local_notification.dart';
import 'package:letsruntogether/common/common_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

import '../../common/back_service.dart';
import '../../common/db_helper.dart';
import '../../common/globs.dart';
import '../../common/service_call.dart';
import '../../common/work_manager_service.dart';
import '../firebasebloc/firebase_use_bloc.dart';
import 'geolocation_event.dart';
import 'geolocation_state.dart';

class GeolocationBloc extends Bloc<GeolocationEvent, GeolocationState> {

  GeolocationBloc() : super(GeolocationInitial()) {
    on<GeolocationEvent>((event, emit) {
      if(event is SetRaceId){
        _setRaceId(event.raceId);
      }else
      if (event is StartLocationTracking) {
        _onStartLocationTracking(event,emit);
      }else
      if (event is StartLocationTracking) {
        _onStartLocationTracking(event,emit);
      }else
      if(event is StopLocationTracking){
        _onStopLocationTracking(event, emit);
      }else
      if(event is ResumeLocationTracking){
        _onResumeLocationTracking(event, emit);
      }else
      if(event is UpdateRaceCompetitorsData){
        updateTime(event.time);
      }else
      if(event is ApiCallingEvent){
        apiCallingLocationUpdate();
      }

    });

  }

  late Stream<Position> positionStream;
  bool is_online = false;
  bool has_just_stopped = false;
  Position currentPosition = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);

  void _onStartLocationTracking(StartLocationTracking event, Emitter<GeolocationState> emit) async {

    is_online = true;

    emit(GeolocationLoading());

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

      final service = FlutterBackgroundService();
      service.startService();
      FlutterBackgroundService().invoke("setAsForeground");

      //showForegroundNotification();

      // positionStream = Geolocator.getPositionStream(
      //   locationSettings: LocationSettings(
      //       accuracy: LocationAccuracy.high,
      //       distanceFilter: 0,
      //       timeLimit: Duration(milliseconds: 10000)
      //   ),
      // );

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    }else {
      print("Location permission denied");
    }

  }

  void _onStopLocationTracking(StopLocationTracking event, Emitter<GeolocationState> emit) async{
    is_online = false;
    has_just_stopped = true;
    isSaveFileLocation = false;
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if(isRunning){
      service.invoke("stopService");
    }
  }

  void _onResumeLocationTracking(ResumeLocationTracking event, Emitter<GeolocationState> emit){
    is_online = true;
  }

  void _setRaceId(String raceId) async{
    this.raceId = raceId;
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    emit(GeolocationSuccess(currentPosition,0));
  }

  String raceId="";

  String time="";

  void updateTime(String time) async{
    this.time = time;
  }

  void apiCallingLocationUpdate() async{

    int distanceRunned = 0;

    if(currentPosition != null && is_online) {
      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (isSaveFileLocation && raceId != 0) {
        try {
          File("$saveFilePath/$raceId.txt")
              .writeAsStringSync(
              '{"latitude":${currentPosition.latitude},'
                  '"longitude":${currentPosition.longitude},'
                  '"time":"${DateTime.now().stringFormat(
                  format: "yyyy-MM-dd HH:mm:ss")}"},', mode: FileMode.append);
        } catch (e) {
          debugPrint(e.toString());
        }
      }

      String locationsString = getRideSaveLocationJsonString();

      locationsString = locationsString.replaceAll(",]", "]");

      List<dynamic> locationList = jsonDecode(locationsString);

      distanceRunned = int.parse(getDistanceRunned(locationList).toStringAsFixed(0));

      String userName = Globs.udValueString("reg_name");
      String userId = Globs.udValueString("reg_number");

      Map<String, dynamic> dataRace = {
        'competitor_id': userId,
        'race_id': raceId,
        'distance_runned': distanceRunned.toString(),
        'time_runned': time,
        'speed': currentPosition.speed.toString(),
        'latitude': currentPosition.latitude.toString(),
        'longitude': currentPosition.longitude.toString(),
        'name': userName
      };

      Globs.updateRunnerData(dataRace);

      addCompetitor(dataRace);

      if(Platform.isAndroid){
        showRunningForegroundNotification(
            currentPosition.latitude,
            currentPosition.longitude,
            distanceRunned/1000,
            currentPosition.speed*3.6
        );
      }

    }else{
      currentPosition = Position(longitude: 0.0,
          latitude: 0.0,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0);
      if (has_just_stopped) {
        has_just_stopped = false;
        emit(GeolocationSuccess(currentPosition,distanceRunned));
        //apiCallingLocationUpdate(position);
      }
    }

  }

  // void apiCallingLocationUpdate() async{
  //
  //   int distanceRunned = 0;
  //
  //   if(currentPosition != null && is_online) {
  //     currentPosition = await Geolocator.getCurrentPosition(
  //       desiredAccuracy: LocationAccuracy.high,
  //     );
  //
  //     if (isSaveFileLocation && raceId != 0) {
  //       try {
  //         File("$saveFilePath/$raceId.txt")
  //             .writeAsStringSync(
  //             '{"latitude":${currentPosition.latitude},'
  //                 '"longitude":${currentPosition.longitude},'
  //                 '"time":"${DateTime.now().stringFormat(
  //                 format: "yyyy-MM-dd HH:mm:ss")}"},', mode: FileMode.append);
  //       } catch (e) {
  //         debugPrint(e.toString());
  //       }
  //     }
  //
  //     String locationsString = getRideSaveLocationJsonString();
  //
  //     locationsString = locationsString.replaceAll(",]", "]");
  //
  //     List<dynamic> locationList = jsonDecode(locationsString);
  //
  //     distanceRunned = int.parse(getDistanceRunned(locationList).toStringAsFixed(0));
  //
  //     String userName = "Pipe Pibe";
  //     String userId = "99999";
  //
  //     Map<String, dynamic> dataRace = {
  //       'DistanceRunned': distanceRunned,
  //       'TimeRunned': time,
  //       'Speed': currentPosition.speed,
  //       'name': userName,
  //     };
  //
  //     Map<String, double> position = {
  //       'latitude': currentPosition.latitude,
  //       'longitude': currentPosition.longitude,
  //     };
  //
  //     dataRace['Location'] = position;
  //
  //     final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('Races');
  //
  //     await _databaseRef.child(raceId)
  //         .child("Competitors")
  //         .child(userId)
  //         .child("RaceData")
  //         .set(dataRace)
  //         .then((value) {
  //       print('Runner data updated');
  //     }).catchError((error) {
  //       print('Failed to update runner data: $error');
  //     });
  //
  //     // if(serviceInstance!=null){
  //     //   String lati = dataRace["Location"]["latitude"].toStringAsFixed(2);
  //     //   String longi = dataRace["Location"]["longitude"].toStringAsFixed(2);
  //     //   String dista = (int.parse(dataRace["DistanceRunned"].toString())/1000).toStringAsFixed(2);
  //     //   String spd = (double.parse(dataRace["Speed"].toString())*3.6).toStringAsFixed(2);
  //     //   serviceInstance?.setForegroundNotificationInfo(title: "Run together Pereira lat: $lati, long: $longi", content: "Distancia: $dista Km - Veloc.:$spd Km/h");
  //     // }
  //
  //     emit(GeolocationSuccess(currentPosition,distanceRunned));
  //
  //   }else{
  //     currentPosition = Position(longitude: 0.0,
  //         latitude: 0.0,
  //         timestamp: DateTime.now(),
  //         accuracy: 0.0,
  //         altitude: 0.0,
  //         altitudeAccuracy: 0.0,
  //         heading: 0.0,
  //         headingAccuracy: 0.0,
  //         speed: 0.0,
  //         speedAccuracy: 0.0);
  //     if (has_just_stopped) {
  //       has_just_stopped = false;
  //       emit(GeolocationSuccess(currentPosition,distanceRunned));
  //       //apiCallingLocationUpdate(position);
  //     }
  //   }
  //
  // }

  bool isSaveFileLocation = false;
  String saveFilePath = "";

  void startRideLocationSave() async{
    try {
      saveFilePath = (await getSavedPath()).path;
      final file = File('$saveFilePath/$raceId.txt');
      if (await file.exists()) {
        await file.delete(); // Deletes the file
      }

      debugPrint('Saved location ---');

      isSaveFileLocation = true;

    } catch (e) {
      debugPrint(e.toString());
    }
  }

  String getRideSaveLocationJsonString(){
    try{
      return "[${File("$saveFilePath/$raceId.txt").readAsStringSync()}]";
    }catch(e){
      debugPrint(e.toString());
      return "[]";
    }
  }

  Future<Directory> getSavedPath(){
    if(Platform.isAndroid){
      return getTemporaryDirectory();
    }else{
      return getApplicationCacheDirectory();
    }
  }

  double getDistanceRunned(List<dynamic> locationList){

    double distance = 0;

    for (int i = 0; i < locationList.length; i++) {
      if(i==0){
        distance = distance + Geolocator.distanceBetween(double.parse(locationList[i]["latitude"].toString()), double.parse(locationList[i]["longitude"].toString()), double.parse(locationList[i]["latitude"].toString()), double.parse(locationList[i]["longitude"].toString()));
      }else{
        distance = distance + Geolocator.distanceBetween(double.parse(locationList[i-1]["latitude"].toString()), double.parse(locationList[i-1]["longitude"].toString()), double.parse(locationList[i]["latitude"].toString()), double.parse(locationList[i]["longitude"].toString()));
      }
    }

    return distance;

  }

  void addCompetitor(Map<String,dynamic> racerData){

    try{
      ServiceCall.post(
          racerData,
          SVKey.svAddCompetitor,
          withSuccess:(responseObj)async{
            if((responseObj[KKey.status] as String? ?? "")=="1"){
              int distance = int.parse(racerData["distance_runned"]);
              emit(GeolocationSuccess(currentPosition,distance));
            }else{
              print(responseObj[KKey.message] as String? ?? "");
            }
          },
          failure: (err) async{
            print(err);
          }
      );
    }catch(e){
      print(e);
    }

  }

}
