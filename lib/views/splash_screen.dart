import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:letsruntogether/common/common_extensions.dart';
import 'package:letsruntogether/views/racings_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
    load();
  }

  void load() async{
    await Future.delayed(const Duration(seconds: 3));
    loadNextScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Color(0xFFF6F6F6), // Background color similar to #F6F6F6
        child: Center(
          child: Image.asset(
            'assets/images/city_marathon.jpg', // Replace with your actual image asset
            fit: BoxFit.cover, // The image will cover the available space
          ),
        ),
      ),
    );
  }

  void loadNextScreen(){
    context.pop();
    context.push(const RacingScreen());
  }

}
