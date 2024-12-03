import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letsruntogether/bloc_use/firebasebloc/firebase_use_bloc.dart';
import 'package:letsruntogether/bloc_use/geolocationbloc/geolocation_bloc.dart';
import 'package:letsruntogether/bloc_use/photoprofile_bloc/photo_profile_bloc.dart';
import 'package:letsruntogether/bloc_use/webservice_bloc_race_detail/webservice_race_detail_bloc.dart';
import 'package:letsruntogether/bloc_use/webservicebloc/webservice_bloc.dart';
import 'package:letsruntogether/views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common/android_local_notification.dart';
import 'common/back_service.dart';
import 'common/socket_manager.dart';

SharedPreferences? prefs;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeNotifications();
  await initializeService();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();

  SocketManager.shared.initSocket();

  runApp(MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => FirebaseUseBloc()),
        BlocProvider(create: (context) => GeolocationBloc()),
        BlocProvider(create: (context) => WebserviceBloc()),
        BlocProvider(create: (context) => WebserviceRaceDetailBloc()),
        BlocProvider(create: (context) => PhotoProfileBloc()),
      ],
      child: MyApp()
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Run Together',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: SplashScreen(),
    );
  }
}