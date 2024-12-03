
import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc_use/geolocationbloc/geolocation_bloc.dart';
import '../bloc_use/geolocationbloc/geolocation_event.dart';
import '../common/firebase_update.dart';

class ChronometerScreen extends StatefulWidget {

  const ChronometerScreen({super.key});

  @override
  State<ChronometerScreen> createState() => ChronometerScreenState();
}

class ChronometerScreenState extends State<ChronometerScreen> {

  late Stopwatch _stopwatch;  // Stopwatch to track elapsed time
  late Timer _timer;  // Timer to update the display every 100ms (for precision)
  bool _isRunning = false;

  @override
  void initState(){
    super.initState();
    _stopwatch = Stopwatch();
  }

  // Start the stopwatch and the timer
  void _startTimer() async{
    _stopwatch.start();
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {

      int milliseconds = _stopwatch.elapsedMilliseconds;  // Total elapsed time in milliseconds
      int hours = milliseconds ~/ 3600000;  // Calculate total hours
      int minutes = (milliseconds % 3600000) ~/ 60000;  // Remaining minutes
      int seconds = (milliseconds % 60000) ~/ 1000;  // Remaining seconds
      int microseconds = milliseconds % 1000;  // Remaining milliseconds, treated as microseconds

      currentTime = '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}:${microseconds.toString().padLeft(3, '0')}';

      if(seconds%15==0 || seconds==0){
        updateUserData(currentTime);
      }

      setState(() {

      });
    });

  }

  // Stop the stopwatch and the timer
  void _stopTimer() {
    _stopwatch.stop();
    _timer.cancel();
  }

  // Toggle between starting and stopping the timer
  void toggleTimer() {
    if (_isRunning) {
      _stopTimer();
    } else {
      _startTimer();
    }
    setState(() {
      _isRunning = !_isRunning;
    });
  }

  @override
  void dispose() {
    if (_isRunning) {
      _stopTimer();
    }
    super.dispose();
  }

  void updateUserData(String currentTime){
    //context.read<GeolocationBloc>().add(UpdateRaceCompetitorsData(currentTime));
    BlocProvider.of<GeolocationBloc>(context).updateTime(currentTime);
  }

  String currentTime = '';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Time Display
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1), // Semi-transparent background
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: 40),
              // Start/Stop Button
              // ElevatedButton(
              //   onPressed: toggleTimer,
              //   style: ElevatedButton.styleFrom(
              //     padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              //     backgroundColor: Colors.white,
              //     foregroundColor: Colors.teal,
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(30),
              //     ),
              //     shadowColor: Colors.black.withOpacity(0.2),
              //     elevation: 10,
              //   ),
              //   child: Text(
              //     _isRunning ? 'Stop Chronometer' : 'Start Chronometer',
              //     style: TextStyle(
              //       fontSize: 18,
              //       fontWeight: FontWeight.bold,
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );

  }


}
