import 'dart:convert';

import '../main.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Globs{

  static const appName = "Pereira Driver";
  static const userPayload = "user_payload";
  static const userId = "user_id";

  static Map<String, dynamic> currentRunnerData = {};

  static const image_link_format = "https://firebasestorage.googleapis.com/v0/b/plataformatransporte-b20ba.appspot.com/o/img%2Fracers_profile%2Fxxxxxxxxxx.jpg?alt=media&token=30d963f5-cca4-41bf-aa11-fbad722e51fd";

  static void updateRunnerData(Map<String, dynamic> crd) {
    currentRunnerData = crd;
  }

  static void showHUD({String status = "loading..."}) async{
    await Future.delayed(const Duration(microseconds: 1));
    EasyLoading.show(status: status);
  }

  static void hideHUD(){
    EasyLoading.dismiss();
  }

  static void udSet(dynamic data, String key){
    var jsonStr = json.encode(data);
    prefs?.setString(key, jsonStr);
  }

  static void udStringSet(String data,String key){
    prefs?.setString(key, data);
  }

  static void udBoolSet(bool data,String key){
    prefs?.setBool(key, data);
  }

  static void udIntSet(int data,String key){
    prefs?.setInt(key, data);
  }

  static void udDoubleSet(double data,String key){
    prefs?.setDouble(key, data);
  }

  static dynamic udValue(String key){
    return json.decode(prefs?.get(key) as String? ?? "{}");
  }

  static String udValueString(String key){
    return prefs?.get(key) as String? ?? "";
  }

  static bool udValueBool(String key){
    return prefs?.getBool(key) ?? false;
  }

  static bool udValueTrueBool(String key){
    return prefs?.getBool(key) ?? true;
  }

  static int udValueInt(String key){
    return prefs?.getInt(key) ?? 0;
  }

  static double udValueDouble(String key){
    return prefs?.getDouble(key) ?? 0.0;
  }

  static void udRemove(String key){
    prefs?.remove(key);
  }

}

class SVKey{
  static const mainUrl = "http://192.168.10.23:3001";
  //static const mainUrl = "http://localhost:3001";
  //static const mainUrl = "https://transportapp.azurewebsites.net";
  static const baseUrl = "$mainUrl/api/";
  static const nodeUrl = mainUrl;

  static const svGetRaces = "${baseUrl}races";
  static const svAddCompetitor = "${baseUrl}add_competitor";
  static const svImageCompetitor = "${baseUrl}save_racer_image";

}

class KKey{
  static const payload = "payload";
  static const result = "result";
  static const status = "status";
  static const message = "message";

  static const authToken = "auth_token";
}

class MSG{
  static const success = "success";
  static const fail = "fail";
}