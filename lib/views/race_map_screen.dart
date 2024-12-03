import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:letsruntogether/bloc_use/firebasebloc/firebase_use_bloc.dart';
import 'package:letsruntogether/bloc_use/firebasebloc/firebase_use_state.dart';
import 'package:letsruntogether/bloc_use/geolocationbloc/geolocation_bloc.dart';
import 'package:letsruntogether/bloc_use/geolocationbloc/geolocation_state.dart';
import 'package:letsruntogether/bloc_use/webservice_bloc_race_detail/webservice_race_detail_bloc.dart';
import 'package:letsruntogether/models/racer_data.dart';

import 'package:http/http.dart' as http;

import 'dart:ui' as ui;

import '../common/firebase_update.dart';
import '../common/globs.dart';
import '../common/socket_manager.dart';

class RaceMapScreen extends StatefulWidget {

  const RaceMapScreen({super.key});

  @override
  _RaceMapScreenState createState() => _RaceMapScreenState();
}

class _RaceMapScreenState extends State<RaceMapScreen> {

  String _mapStyle = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.loadString('assets/maps/uber_map.json').then((string) {
      _mapStyle = string;
    });
  }

  late GoogleMapController mapController;

  static const LatLng _initialPosition = LatLng(37.7749, -122.4194);

  Position? position = null;
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;
  final initialCameraPosition = const CameraPosition(
      target: LatLng(4.8, -75.7), zoom: 15.0
  );

  Set<Marker> markersSet = {};

  Map<String, BitmapDescriptor> bitmapCache = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<GeolocationBloc, GeolocationState>(
            builder: (context, state) {
              if (state is GeolocationSuccess) {
                position = state.position;
                LatLng latLng = LatLng(position!.latitude, position!.longitude);
                CameraPosition cameraPosition = new CameraPosition(
                    target: latLng, zoom: 16);
                if (newGoogleMapController != null) {
                  newGoogleMapController?.animateCamera(
                      CameraUpdate.newCameraPosition(cameraPosition));
                }

                return BlocBuilder<WebserviceRaceDetailBloc, WebserviceRaceDetailState>(
                  builder: (context, state) {

                    if(state is GetRacersDataSuccess){
                      markersSet.clear();
                      Set<Marker> driversMarkerSet = Set<Marker>();

                      for(RacerData racerData in state.racersData){

                        RacerData rd = racerData;

                        LatLng driverPos = LatLng(rd.latitude!,rd.longitude!);

                        BitmapDescriptor userImg;
                        if (bitmapCache.containsKey(rd.racer_id)) {
                          userImg = bitmapCache[rd.racer_id]!;
                        } else {
                          createCustomMarker(rd).then((markerImg) {
                            bitmapCache[rd.racer_id] = markerImg;
                            driversMarkerSet.add(Marker(
                              markerId: MarkerId(rd.racer_id.toString()),
                              position: driverPos,
                              icon: markerImg,
                              infoWindow: InfoWindow(title: rd.name),
                            ));
                          });
                          continue;
                        }

                        driversMarkerSet.add(Marker(
                          markerId: MarkerId(rd.racer_id.toString()),
                          position: driverPos,
                          icon: userImg,
                          infoWindow: InfoWindow(title: rd.name),
                        ));

                      }
                      markersSet = driversMarkerSet;
                    }
                    return GoogleMap(
                      onMapCreated: (GoogleMapController controller) {
                        _controllerGoogleMap.complete(controller);
                        newGoogleMapController = controller;
                      },
                      style: _mapStyle,
                      initialCameraPosition: initialCameraPosition,
                      mapType: MapType.normal,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                      markers: markersSet,
                    );
                  },
                );

                // return BlocBuilder<FirebaseUseBloc, FirebaseUseState>(
                //   builder: (context, state) {
                //     if(state is RacersDataLoadedState){
                //       markersSet.clear();
                //       Set<Marker> driversMarkerSet = Set<Marker>();
                //
                //       for(RacerData rd in state.items){
                //
                //         LatLng driverPos = LatLng(rd.latitude!,rd.longitude!);
                //
                //         List<String> names = rd.name.split(" ");
                //
                //         String initials = "";
                //
                //         names.forEach((name) {
                //           initials += name[0].toUpperCase();
                //         });
                //
                //         BitmapDescriptor userImg;
                //         if (bitmapCache.containsKey(rd.racer_id)) {
                //           userImg = bitmapCache[rd.racer_id]!;
                //         } else {
                //           createCustomMarker(initials).then((markerImg) {
                //             bitmapCache[rd.racer_id] = markerImg;
                //             driversMarkerSet.add(Marker(
                //               markerId: MarkerId(rd.racer_id.toString()),
                //               position: driverPos,
                //               icon: markerImg,
                //               infoWindow: InfoWindow(title: rd.name),
                //             ));
                //           });
                //           continue;
                //         }
                //
                //         driversMarkerSet.add(Marker(
                //           markerId: MarkerId(rd.racer_id.toString()),
                //           position: driverPos,
                //           icon: userImg,
                //           infoWindow: InfoWindow(title: rd.name),
                //         ));
                //
                //       }
                //       markersSet = driversMarkerSet;
                //     }
                //     return GoogleMap(
                //       onMapCreated: (GoogleMapController controller) {
                //         _controllerGoogleMap.complete(controller);
                //         newGoogleMapController = controller;
                //       },
                //       initialCameraPosition: initialCameraPosition,
                //       mapType: MapType.normal,
                //       myLocationEnabled: true,
                //       myLocationButtonEnabled: true,
                //       markers: markersSet,
                //     );
                //   },
                // );
              } else {
                return GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;
                  },
                  initialCameraPosition: initialCameraPosition,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: markersSet,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    newGoogleMapController?.dispose();
    super.dispose();
  }

  Future<BitmapDescriptor> createCustomMarker(RacerData rd) async {

    final imageUrl = Globs.image_link_format.replaceAll("xxxxxxxxxx", rd.racer_id); // Replace with your image URL
    final response = await http.get(Uri.parse(imageUrl));

    if (response.statusCode == 200) {

      final Uint8List bytes = response.bodyBytes;

      final ui.Image image = await _loadImageFromBytes(bytes);

      // Create a circular image from the loaded image
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);

      // Define the circle to clip the image
      final double radius = image.width / 2;
      final Offset center = Offset(image.width / 2, image.height / 2);
      final Rect rect = Rect.fromCircle(center: center, radius: radius);

      // Clip the image to a circle
      canvas.clipPath(Path()..addOval(rect));

      // Draw the image onto the canvas
      canvas.drawImage(image, Offset(0, 0), Paint());

      final ui.Picture picture = pictureRecorder.endRecording();
      final ui.Image clippedImage = await picture.toImage(image.width, image.height);

      // Convert the clipped image to bytes
      final ByteData? byteData = await clippedImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List byteList = byteData!.buffer.asUint8List();

      // Return the BitmapDescriptor created from the byteList
      return BitmapDescriptor.fromBytes(byteList);

    } else {
      List<String> names = rd.name.split(" ");

      String initials = "";

      names.forEach((name) {
        initials += name[0].toUpperCase();
      });

      final textPainter = TextPainter(
        text: TextSpan(
          text: initials,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      // Define a size for the circle
      const double size = 100.0;  // Marker size (diameter)

      // Create an image of the marker
      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder, Rect.fromPoints(Offset(0, 0), Offset(size, size)));

      // Paint the circle with a background color
      final paintCircle = Paint()..color = getRandomMetallicColor();
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2, paintCircle);

      // Prepare the text to draw on the circle
      textPainter.layout(minWidth: 0, maxWidth: size);
      textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

      // Create the final image
      final picture = pictureRecorder.endRecording();
      final img = await picture.toImage(size.toInt(), size.toInt());

      // Convert the image to a BitmapDescriptor
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final buffer = bytes!.buffer.asUint8List();
      return BitmapDescriptor.fromBytes(buffer);
    }
  }

  Future<ui.Image> _loadImageFromBytes(Uint8List bytes) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(bytes, (ui.Image img) {
      completer.complete(img);
    });
    return completer.future;
  }

  Color getRandomMetallicColor() {
    // Random instance to generate random values
    Random random = Random();

    // Generate random values for hue, saturation, and lightness
    double hue = random.nextDouble() * 360; // Random hue (metallic colors tend to have a certain hue range)
    double saturation = 0.5 + random.nextDouble() * 0.3; // Higher saturation for metallic shine (0.5 to 0.8)
    double lightness = 0.5 + random.nextDouble() * 0.3; // Medium to high lightness for metallic colors

    // Create metallic tones (around gold, silver, copper, and bronze)
    // Use some specific hues for gold, copper, silver
    if (hue < 60) hue = 55.0; // Gold-ish hue
    else if (hue < 120) hue = 60.0; // Silver-ish tone
    else if (hue < 180) hue = 20.0; // Copper-ish tone
    else hue = random.nextDouble() * 360; // Random metallic hues

    // Convert HSL to RGB Color
    return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
  }

}