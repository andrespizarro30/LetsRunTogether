import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letsruntogether/bloc_use/webservicebloc/webservice_bloc.dart';
import 'package:letsruntogether/models/racer_data.dart';
import 'package:letsruntogether/views/runner_card_position_screen.dart';

import '../bloc_use/webservice_bloc_race_detail/webservice_race_detail_bloc.dart';

class RunnersDataScreen extends StatefulWidget {

  const RunnersDataScreen({super.key});

  @override
  State<RunnersDataScreen> createState() => _RunnersDataScreenState();
}

class _RunnersDataScreenState extends State<RunnersDataScreen> {

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late AnimatedListState _animatedListState;

  @override
  void initState() {
    super.initState();
  }

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
        child: Padding(
          padding: const EdgeInsets.only(bottom: 50),
          child: BlocBuilder<WebserviceRaceDetailBloc, WebserviceRaceDetailState>(
            builder: (context, state) {
              if (state is GetRacersDataSuccess) {
                List racers = state.racersData;

                return ListView.builder(
                  itemCount: racers.length, // Number of items in the list
                  itemBuilder: (context, index) {
                    RacerData racerData = racers[index];
                    racerData.position = index + 1;
                    return RunnerCardScreen(racerData: racerData);
                  },
                );
              } else if (state is GetRacersDataLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else if (state is GetRacersDataEmpty) {
                return Center(
                  child: Text(
                    "No racers available",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else if (state is GetRacersDataError) {
                return Center(
                  child: Text(
                    state.error,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}