
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommonExtensions{


}

extension AppContext on BuildContext{

  Size get size => MediaQuery.sizeOf(this);
  double get width => size.width;
  double get heigth => size.height;

  MediaQueryData get queryData => MediaQuery.of(this);

  Future push(Widget widget) async{
    return Navigator.push(this, MaterialPageRoute(builder: (context)=> widget));
  }

  void pop() async{
    return Navigator.pop(this);
  }

}

extension MDExtensionState on State{
  void mdShowAlert(String title,
      String message,
      VoidCallback onPressed,
      {String buttonTitle = "OK",
        TextAlign mainTextAlignment = TextAlign.center,
        isForce = false
      }){

    showDialog(
        context: context,
        barrierDismissible: !isForce,
        builder: (context){
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text(buttonTitle),
                isDefaultAction: true,
                onPressed: (){
                  Navigator.pop(context);
                  onPressed();
                },
              )
            ],
          );
        }
    );
  }

  void mdShowAlert_auto_closing(String title,
      String message,
      VoidCallback onPressed,
      {String buttonTitle = "OK",
        TextAlign mainTextAlignment = TextAlign.center,
        isForce = false
      }){

    showDialog(
        context: context,
        barrierDismissible: !isForce,
        builder: (context){

          Future.delayed(Duration(seconds: 3), () {
            Navigator.of(context).pop();
          });

          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text(buttonTitle),
                isDefaultAction: true,
                onPressed: (){

                },
              )
            ],
          );
        }
    );
  }

  void endEditing(){
    FocusScope.of(context).requestFocus(FocusNode());
  }

}

extension StringExtension on String{
  bool get isEmail{
    return RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$").hasMatch(this);
  }

  DateTime dataFormat({String format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", int addMin=0}){
    var date = (DateFormat(format).parseUTC(this));
    return date.add(Duration(minutes: addMin));
  }

  String timeAgo({int addMin = 0}){

    if(this == ""){
      return "";
    }
    return timeago.format(dataFormat());
  }

  String stringFormatToOtherFormat({String format = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'",String newFormat = "dd/MM/yyyy", int addMin = 0}){

    try{
      var date = DateFormat(format).parse(this);
      if(date==null){
        return "";
      }
      return date.add(Duration(minutes: addMin)).stringFormat(format: newFormat);
    }catch(e){
      return "";
    }
  }

  DateTime get date{
    return DateFormat('yyyy/MM/dd').parse(this);
  }

  DateTime get dateTime{
    return DateFormat('yyyy/MM/dd HH:mm').parse(this);
  }

}

extension DateTimeExtension on DateTime{
  String stringFormat({String format = "yyyy-MM-dd"}){
    return DateFormat(format).format(this);
  }
}