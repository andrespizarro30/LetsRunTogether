
import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsruntogether/common/globs.dart';
import 'package:letsruntogether/common/service_call.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc_use/geolocationbloc/geolocation_bloc.dart';
import '../bloc_use/geolocationbloc/geolocation_event.dart';
import '../main.dart';
import '../views/racing_details_screen.dart';
import 'db_helper.dart';

Future<void> initializeService() async{

  final service = FlutterBackgroundService();
  await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          isForegroundMode: true,
          autoStart: true,
          foregroundServiceTypes: [
            AndroidForegroundType.dataSync, // For background data synchronization
          ],
          // notificationChannelId: 'tracking_race',
          // initialNotificationTitle: 'Run together',
          // initialNotificationContent: 'Starting race',
          // foregroundServiceNotificationId: 999,
      )
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async{
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service){

  DartPluginRegistrant.ensureInitialized();

  if(service is AndroidServiceInstance){
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });
    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  int i = 0;
  int min = 0;
  UpdateRunnerData updateRunnerData = UpdateRunnerData();

  Timer.periodic(const Duration(seconds: 15), (timer) async{
    if(service is AndroidServiceInstance){
      if(await service.isForegroundService()){
        if(i%4==0){
          min += 1;
          service.setForegroundNotificationInfo(title: "Run together Pereira", content: "Tiempo: $min min");
        }if(i==0){
          service.setForegroundNotificationInfo(title: "Run together Pereira", content: "Tiempo: $min min");
        }
      }
    }
    //updateRunnerData.updateRunnerData();
    i += 1;
    //service.invoke('update');
  });

}

class UpdateRunnerData{

  void updateRunnerData(){
    try{
      ServiceCall.post(
          {

          },
          SVKey.svAddCompetitor,
          withSuccess:(responseObj)async{
            if((responseObj[KKey.status] as String? ?? "")=="1"){
              print(responseObj[KKey.message] as String? ?? "");
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