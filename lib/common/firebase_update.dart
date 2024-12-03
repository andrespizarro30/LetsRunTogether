import 'dart:convert';
import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsruntogether/common/common_extensions.dart';
import 'package:path_provider/path_provider.dart';

import 'back_service.dart';

class FirebaseUpdate{

  bool is_online = false;
  bool has_just_stopped = false;
  Position currentPosition = Position(longitude: 0.0, latitude: 0.0, timestamp: DateTime.now(), accuracy: 0.0, altitude: 0.0, altitudeAccuracy: 0.0, heading: 0.0, headingAccuracy: 0.0, speed: 0.0, speedAccuracy: 0.0);


  void onStartLocationTracking() async{

    is_online = true;

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

      // await initializeService();
      final service = FlutterBackgroundService();
      service.startService();
      FlutterBackgroundService().invoke("setAsForeground");

      currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

    }else {
      print("Location permission denied");
    }

    String a = "";

  }

  bool isSaveFileLocation = false;
  String saveFilePath = "";

  void onStopLocationTracking() async{
    is_online = false;
    has_just_stopped = true;
    isSaveFileLocation = false;
    final service = FlutterBackgroundService();
    bool isRunning = await service.isRunning();
    if(isRunning){
      service.invoke("stopService");
    }
  }

  void onResumeLocationTracking(){
    is_online = true;
  }

  String raceId="0";
  String time="";

  void setRaceId(String raceId) async{
    this.raceId = raceId;
    currentPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void timeUpdate(String time) async{
    this.time = time;
  }

  void apiCallingLocationUpdate() async{

    int distanceRunned = 0;

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

    String userName = "Pipe Pibe";
    String userId = "99999";

    Map<String, dynamic> dataRace = {
      'DistanceRunned': distanceRunned,
      'TimeRunned': time,
      'Speed': currentPosition.speed,
      'name': userName,
    };

    Map<String, double> position = {
      'latitude': currentPosition.latitude,
      'longitude': currentPosition.longitude,
    };

    dataRace['Location'] = position;

    final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('Races');

    await _databaseRef.child(raceId)
        .child("Competitors")
        .child(userId)
        .child("RaceData")
        .set(dataRace)
        .then((value) {
      print('Runner data updated');
    }).catchError((error) {
      print('Failed to update runner data: $error');
    });

  }

  void startRideLocationSave() async{
    try {

      is_online = is_online;

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

}