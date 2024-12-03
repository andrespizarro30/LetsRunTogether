import 'dart:io';
import 'dart:isolate';
import 'dart:ui';


import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:letsruntogether/bloc_use/firebasebloc/firebase_use_bloc.dart';
import 'package:letsruntogether/bloc_use/photoprofile_bloc/photo_profile_bloc.dart';
import 'package:letsruntogether/bloc_use/webservicebloc/webservice_bloc.dart';
import 'package:letsruntogether/common/common_extensions.dart';
import 'package:letsruntogether/common_widgets/popup_layout.dart';
import 'package:letsruntogether/models/races_data.dart';
import 'package:letsruntogether/views/racing_details_screen.dart';
import 'package:letsruntogether/views/racings_card_screen.dart';

import '../bloc_use/firebasebloc/firebase_use_event.dart';
import '../bloc_use/firebasebloc/firebase_use_state.dart';

import 'package:permission_handler/permission_handler.dart';

import '../common/fit_controller.dart';
import '../common/globs.dart';
import '../common/service_call.dart';
import '../common_widgets/image_picker_view.dart';
import '../models/ws_race_data.dart';

class RacingScreen extends StatefulWidget {

  const RacingScreen({super.key});

  @override
  State<RacingScreen> createState() => _RacingScreenState();
}

class _RacingScreenState extends State<RacingScreen> {

  File? profileImage;

  List<RacesData> racesData = [];

  TextEditingController tecFindRace = TextEditingController();

  TextEditingController tecName = TextEditingController();
  TextEditingController tecCelNumber = TextEditingController();

  @override
  void initState() {
    super.initState();

    tecFindRace.addListener(() {
      filterRaces();
    });

    requestNotificationPermission();

  }

  void filterRaces() {
    String query = tecFindRace.text.toLowerCase();
    //context.read<FirebaseUseBloc>().filterRacesData(query);
    context.read<WebserviceBloc>().filterRacesData(query);
  }

  @override
  void dispose() {
    // Dispose of the controller when no longer needed
    tecFindRace.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      //context.read<FirebaseUseBloc>().add(GetRacesEvent());
      context.read<WebserviceBloc>().add(GetRacesEv());
    });

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              title: Text('Carreras'),
              backgroundColor: Colors.white,
              elevation: 4.0,
              floating: false,
              pinned: true,
              expandedHeight: 60.0,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: Colors.white,
                ),
              ),
              actions: [
                PopupMenuButton<int>(
                  onSelected: (int value) {
                    if (value == 0) {
                      showProfileDialog(context);
                    }else
                    if (value == 1) {
                      requestPermissions();
                    }
                  },
                  color: Colors.teal,
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem<int>(
                      value: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal, Colors.blueAccent],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(10), // Rounded corners
                        ),
                        padding: EdgeInsets.all(10), // Padding inside the menu item
                        child: Text(
                          'Registrarme',
                          style: TextStyle(
                            color: Colors.white, // Text color to contrast with the gradient
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // PopupMenuItem<int>(
                    //   value: 1,
                    //   child: Text('Smartswatch'),
                    // ),
                  ],
                ),
              ],
            ),
          ];
        },
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title TextView
              Text(
                'Encuentra tu próximo objetivo',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                maxLines: 2,
              ),
              SizedBox(height: 16.0),

              // SearchView
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey),
                ),
                child: TextField(
                  controller: tecFindRace,
                  decoration: InputDecoration(
                    hintText: 'Find race',
                    border: InputBorder.none,
                    icon: Icon(Icons.search),
                  ),
                ),
              ),
              SizedBox(height: 24.0),

              // Subtitle TextView
              Text(
                'Races',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 16.0),

              BlocBuilder<WebserviceBloc, WebserviceState>(
                builder: (context, state) {
                  if(state is GetRacesSuccess){

                    List races = state.racesData;

                    return Expanded(
                      child: ListView.builder(
                        itemCount: races.length,
                        itemBuilder: (context, index) {

                          WSRaceData raceData = WSRaceData.fromMap(races[index]);

                          return InkWell(
                              onTap: () {
                                var reg_name = Globs.udValueString("reg_name");
                                var reg_phone = Globs.udValueString("reg_number");
                                if(reg_name.isNotEmpty && reg_phone.isNotEmpty){
                                  context.push(RaceDetailsScreen(raceId: raceData.race_id,));
                                }else{
                                  mdShowAlert("Run together Pereira","Realice primero un registro (⋮ menú)",(){});
                                }
                              },
                              child: RacingCardScreen(racesData: raceData,)
                          );
                        },
                      ),
                    );
                  }else
                  if(state is GetRacesLoading){
                    return Center(child: CircularProgressIndicator(),);
                  }
                  else{
                    return Center(child: Text("No hay carrera disponibles"),);
                  }
                },
              ),
              // RecyclerView equivalent - ListView
              // BlocBuilder<FirebaseUseBloc, FirebaseUseState>(
              //   builder: (context, state) {
              //     if(state is RacesDataLoadedState){
              //       racesData = state.items;
              //       return Expanded(
              //         child: ListView.builder(
              //           itemCount: racesData.length, // Example list count
              //           itemBuilder: (context, index) {
              //
              //             RacesData raceData = racesData[index];
              //
              //             return InkWell(
              //                 onTap: () {
              //                   context.push(RaceDetailsScreen(raceId: raceData.race_id,));
              //                 },
              //                 child: RacingCardScreen(racesData: raceData,)
              //             );
              //           },
              //         ),
              //       );
              //     }else
              //     if(state is RacesDataLoadingState){
              //       return Center(child: CircularProgressIndicator(),);
              //     }else
              //     if(state is RacersDataLoadedState || state is RacersDataEmptyLoadedState || state is RacesDataErrorState){
              //       return Expanded(
              //         child: ListView.builder(
              //           itemCount: racesData.length, // Example list count
              //           itemBuilder: (context, index) {
              //
              //             RacesData raceData = racesData[index];
              //
              //             return InkWell(
              //                 onTap: () {
              //                   context.push(RaceDetailsScreen(raceId: raceData.race_id,));
              //                 },
              //                 child: RacingCardScreen(racesData: raceData,)
              //             );
              //           },
              //         ),
              //       );
              //     }
              //     else{
              //       return Center(child: Text("No hay carrera disponibles"),);
              //     }
              //   },
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> requestNotificationPermission() async {
    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isGranted) {
        print("Notification permission granted");
      } else {
        print("Notification permission denied");
      }
    }
  }

  void showProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal, Colors.blueAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile Image with Edit Icon
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10)
                              ]),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: BlocBuilder<PhotoProfileBloc, PhotoProfileState>(
                              builder: (context, state) {
                                if (state is GetImageProfileSuccess) {
                                  profileImage = state.imageFile;
                                  return Image.file(
                                    profileImage!,
                                    width: 200,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Icon(
                                    Icons.person,
                                    size: 200,
                                    color: Colors.blueAccent,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue, size: 28),
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              PopupLayout(child: ImagePickerView()),
                            );
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                
                    // Name Text Field
                    TextField(
                      controller: tecName,
                      decoration: InputDecoration(
                        labelText: 'Nombre (Apodo)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white, // Background of text field
                      ),
                    ),
                    SizedBox(height: 10),
                
                    // Phone Number Text Field
                    TextField(
                      controller: tecCelNumber,
                      decoration: InputDecoration(
                        labelText: 'Celular',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white, // Background of text field
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                
                    // Accept Button
                    ElevatedButton(
                      onPressed: () async {
                        Globs.udStringSet(tecName.text, "reg_name");
                        Globs.udStringSet(tecCelNumber.text, "reg_number");
                        await saveImageProfile({"image": profileImage!}, tecCelNumber.text);
                        Navigator.pop(context); // Close the dialog
                      },
                      child: Text('Registrame'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 40),
                        backgroundColor: Colors.blueAccent, // Background color for button
                        foregroundColor: Colors.white, // Text color
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> saveImageProfile(Map<String,File> imagePara,String fileName) async{
    Globs.showHUD();
    ServiceCall.multiPart(
        {
          "file_name": fileName
        },
        SVKey.svImageCompetitor,
        isTokenApi: true,
        imgObj: imagePara,
        withSuccess: (responseObj) async{
          if((responseObj[KKey.status] ?? "")=="1"){
            Globs.hideHUD();
            mdShowAlert("",responseObj[KKey.message] ?? MSG.success,(){});
          }else{
            Globs.hideHUD();
          }
        },
        failure: (err) async{
          Globs.hideHUD();
        }
    );
  }

}
