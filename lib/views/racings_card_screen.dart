import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/races_data.dart';
import '../models/ws_race_data.dart';

class RacingCardScreen extends StatelessWidget {

  //final RacesData racesData;
  final WSRaceData racesData;

  const RacingCardScreen({super.key, required this.racesData});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 30.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Rounded corners
      ),
      margin: EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.lightBlue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15), // Match card shape
        ),
        height: 100,
        child: Row(
          children: [
            // Left: Text Content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Race ID Text
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        racesData.race_id,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Date Text
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5.0),
                      child: Text(
                        racesData.dates,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Right: Image
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: CachedNetworkImage(
                imageUrl: racesData.logo as String? ?? "",
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                placeholder: (context, url) => Center(
                  child: Image.asset(
                    "assets/images/city_marathon.jpg",
                    width: 50,
                    height: 50,
                  ), // Placeholder image
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.error,
                  color: Colors.redAccent,
                  size: 50,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}