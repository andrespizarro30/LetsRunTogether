import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:letsruntogether/bloc_use/webservicebloc/webservice_bloc.dart';
import 'package:letsruntogether/common_widgets/chronometer_screen.dart';
import 'package:letsruntogether/views/racing_details_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../bloc_use/geolocationbloc/geolocation_bloc.dart';
import '../bloc_use/geolocationbloc/geolocation_event.dart';

import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart' as locDto;
import 'package:background_locator_2/settings/android_settings.dart' as androidSet;
import 'package:background_locator_2/settings/ios_settings.dart' as iosSet;
import 'package:background_locator_2/settings/locator_settings.dart' as locSet;

import '../bloc_use/geolocationbloc/geolocation_state.dart';
import '../common/android_local_notification.dart';
import '../common/back_service.dart';
import '../common/firebase_update.dart';
import '../common/work_manager_service.dart';


class RaceTimeScreen extends StatefulWidget {

  const RaceTimeScreen({super.key});

  @override
  _RaceTimeScreenState createState() => _RaceTimeScreenState();
}


class _RaceTimeScreenState extends State<RaceTimeScreen> {

  late GlobalKey<ChronometerScreenState> _chronometerKey;

  ReceivePort port = ReceivePort();

  late final Timer timer;

  @override
  void initState() {
    super.initState();
    _chronometerKey = GlobalKey<ChronometerScreenState>();

    if (IsolateNameServer.lookupPortByName("Tracking") != null) {
      IsolateNameServer.removePortNameMapping("Tracking");
    }

    IsolateNameServer.registerPortWithName(port.sendPort, "Tracking");

    port.listen((dynamic data) async {

    },
    );

    //initializeNotifications();
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    // print('Initializing...');
    // await BackgroundLocator.initialize();
    // print('Initialization done');
    // final _isRunning = await BackgroundLocator.isServiceRunning();
    // print('Running ${_isRunning.toString()}');
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true
    );
  }

  bool isRaceStarted = false; // Should be false initially
  bool isCardDistanceVisible = true; // Initially false
  bool isCardTimeVisible = true; // Initially false
  bool isDarkScreenVisible = true; // Initially false

  // Function to toggle state
  void toggleRaceStart() {
    setState(() {
      isRaceStarted = !isRaceStarted;
      // isCardDistanceVisible = !isCardDistanceVisible;
      // isCardTimeVisible = !isCardTimeVisible;
      // isDarkScreenVisible = !isDarkScreenVisible;
    });
  }

  int _counter = 3; // Start from 3
  late Timer _timer;

  void startRacing() {
    setState(() {
      isRaceStarted = !isRaceStarted;
    });
    _timer = Timer.periodic(Duration(milliseconds: 1500), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--; // Decrease counter every second
        });
      } else {
        setState(() {
          _counter--; // Decrease counter every second
        });
        _timer.cancel(); // Stop the timer when the countdown reaches 0
        _chronometerKey.currentState?.toggleTimer();
        if (isRaceStarted) {
          getPositionRace();
        } else {
          stopPositionRace();
        }
      }
    });
  }

  void getPositionRace() async {
    //firebaseUpdate.startRideLocationSave();
    //firebaseUpdate.onStartLocationTracking();
    BlocProvider.of<GeolocationBloc>(context).startRideLocationSave();
    BlocProvider.of<GeolocationBloc>(context).add(StartLocationTracking());

    timer = Timer.periodic(const Duration(seconds: 15), (timer) async {
      BlocProvider.of<GeolocationBloc>(context).apiCallingLocationUpdate();
    });

    //await startLocator();
  }

  void stopPositionRace() async {
    //firebaseUpdate.onStopLocationTracking();
    BlocProvider.of<GeolocationBloc>(context).add(StopLocationTracking());
  }

  void stopRacing() {
    _timer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueAccent,
      body: StreamBuilder<Map<String, dynamic>?>(
        stream: FlutterBackgroundService().on('update'),
        builder: (context, snapshot) {
          return Stack(
            children: [
              // Dark Screen
              Visibility(
                visible: isDarkScreenVisible,
                child: Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: Text(
                        _counter >= 0 ? _counter.toString() : "GO",
                        style: TextStyle(
                          fontSize: 100,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Card for Distance
              Visibility(
                visible: isCardDistanceVisible,
                child: Positioned(
                  top: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 20.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      height: 270,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: BlocBuilder<GeolocationBloc, GeolocationState>(
                        builder: (context, state) {
                          if (state is GeolocationSuccess) {
                            int mts = state.dist;
                            String kms = (mts / 1000).toStringAsFixed(2);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '$mts mts',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '$kms km',
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            );
                          } else {
                            return Center(
                              child: Text(
                                "...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // Card for Time
              Visibility(
                visible: isCardTimeVisible,
                child: Positioned(
                  bottom: 10,
                  left: 10,
                  right: 10,
                  child: Card(
                    elevation: 20.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Container(
                      height: 270,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.teal, Colors.blueAccent],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Center(
                        child: ChronometerScreen(key: _chronometerKey),
                      ),
                    ),
                  ),
                ),
              ),

              // Play/Stop Button
              Positioned(
                bottom: MediaQuery.of(context).size.height / 2,
                right: 20,
                child: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRaceStarted ? Icons.stop : Icons.play_arrow,
                      size: 40,
                      color: Colors.lightBlue,
                    ),
                  ),
                  onPressed: () {
                    startRacing();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );

  }

  @override
  void dispose() {
    try {
      _timer.cancel();
    } catch (e) {

    }

    BackgroundLocator.unRegisterLocationUpdate();

    super.dispose();
  }

  Future<void> startLocator() async {
    Map<String, dynamic> data = {'countInit': 1};

    //listenLocations();

    // var service = BackgroundLocator.registerLocationUpdate(locationCallback,
    //     initCallback: initCallback,
    //     initDataCallback: data,
    //     disposeCallback: disposeCallback,
    //     iosSettings: iosSet.IOSSettings(
    //         accuracy: locSet.LocationAccuracy.NAVIGATION,
    //         distanceFilter: 0,
    //         stopWithTerminate: true
    //     ),
    //     autoStop: false,
    //     androidSettings: androidSet.AndroidSettings(
    //         accuracy: locSet.LocationAccuracy.NAVIGATION,
    //         interval: 0,
    //         distanceFilter: 0,
    //         client: androidSet.LocationClient.google,
    //         androidNotificationSettings: androidSet.AndroidNotificationSettings(
    //             notificationChannelName: 'Location tracking',
    //             notificationTitle: 'Corriendo...',
    //             notificationMsg: 'Run together Pereira',
    //             notificationBigMsg: 'Vamos por el objetivo',
    //             notificationIconColor: Colors.grey,
    //             notificationTapCallback:
    //             notificationTapCallback)));

    final _isRunning = await BackgroundLocator.isServiceRunning();
    print('Running ${_isRunning.toString()}');

    // return service;
  }

  void locationCallback(locDto.LocationDto locationDto) {
    print('New location: ${locationDto.latitude}, ${locationDto.longitude}');

    _updateNotificationText(locationDto);
  }

  void initCallback(Map<String, dynamic> init) {

  }

  void notificationTapCallback() {

  }

  void disposeCallback() {

  }

  void listenLocations() {
    // final locationListener = BlocProvider.of<GeolocationBloc>(context);
    //
    // locationListener.stream.listen((state) {
    //   if (state is GeolocationSuccess) {
    //     // showForegroundNotification(
    //     //     state.position.latitude,
    //     //     state.position.longitude,
    //     //     state.dist/1000,
    //     //     state.position.speed*3.6
    //     // );
    //   }
    // });

  }

  Future<void> _updateNotificationText(locDto.LocationDto data) async {
    if (data == null) {
      return;
    }

    await BackgroundLocator.updateNotificationText(
        title: "new location received",
        msg: "${DateTime.now()}",
        bigMsg: "${data.latitude}, ${data.longitude}");
  }

}

void onStart() {
  print("Service started");
}