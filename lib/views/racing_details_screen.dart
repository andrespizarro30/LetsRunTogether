import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:letsruntogether/bloc_use/firebasebloc/firebase_use_event.dart';
import 'package:letsruntogether/bloc_use/geolocationbloc/geolocation_bloc.dart';
import 'package:letsruntogether/bloc_use/geolocationbloc/geolocation_event.dart';
import 'package:letsruntogether/bloc_use/webservice_bloc_race_detail/webservice_race_detail_bloc.dart';
import 'package:letsruntogether/models/races_data.dart';
import 'package:letsruntogether/views/race_map_screen.dart';
import 'package:letsruntogether/views/race_positions_screen.dart';
import 'package:letsruntogether/views/race_time_screen.dart';
import 'package:letsruntogether/views/runner_card_position_screen.dart';
import 'package:permission_handler/permission_handler.dart';

import '../bloc_use/firebasebloc/firebase_use_bloc.dart';
import '../bloc_use/firebasebloc/firebase_use_bloc.dart';
import '../bloc_use/webservicebloc/webservice_bloc.dart';
import '../common/firebase_update.dart';

class RaceDetailsScreen extends StatefulWidget {

  final String raceId;

  const RaceDetailsScreen({super.key, required this.raceId});

  @override
  _RaceDetailsScreenState createState() => _RaceDetailsScreenState();
}

class _RaceDetailsScreenState extends State<RaceDetailsScreen> {

  int _selectedIndex = 0;

  List<Widget> _widgetOptions = <Widget>[
    RaceTimeScreen(),
    RaceMapScreen(),
    RunnersDataScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<void> requestPermissions() async {
    // Request both foreground and background location permissions
    var status = await Permission.location.request();
    if (status.isGranted) {
      var backgroundStatus = await Permission.locationAlways.request();
      if (backgroundStatus.isGranted) {
        print('Location permissions granted');
      } else {
        print('Location permissions denied');
      }
    } else {
      print('Location permission denied');
    }
  }

  @override
  Widget build(BuildContext context) {

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      context.read<FirebaseUseBloc>().add(GetRaceCompetitorsEvent(widget.raceId));
      context.read<GeolocationBloc>().add(SetRaceId(widget.raceId));
      BlocProvider.of<WebserviceRaceDetailBloc>(context).setSocketListeners(widget.raceId);

      requestPermissions();

      // LocationPermission permission = await Geolocator.checkPermission();
      // if (permission == LocationPermission.denied) {
      //   permission = await Geolocator.requestPermission();
      // }
      //
      // if (permission == LocationPermission.deniedForever) {
      //
      // } else if (permission == LocationPermission.whileInUse ||
      //     permission == LocationPermission.always) {
      // }

    });

    return Scaffold(
      body: Stack(
        children: [

          IndexedStack(
            index: _selectedIndex,
            children: _widgetOptions,
          ),

          // Bottom Navigation Bar
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.run_circle),
                  label: 'Run',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map Race',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.place),
                  label: 'Race Positions',
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              backgroundColor: Colors.white,
              selectedItemColor: Colors.blue,
              unselectedItemColor: Colors.grey,
              elevation: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

}