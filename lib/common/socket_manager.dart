import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'globs.dart';

class SocketManager{

  static final SocketManager singleton = SocketManager._internal();

  SocketManager._internal();

  IO.Socket? socket;

  static SocketManager get shared => singleton;

  void initSocket(){
    socket = IO.io(SVKey.mainUrl,{
      "transports":['websocket'],
      "autoConnect": true
    });

    socket?.on("connect",(data){
      if(kDebugMode){
        print("Socket Connect Done");
      }
      //Emit method
      updateSocketIdApi();
    });

    socket?.on("connect error", (data){
      if(kDebugMode){
        print("Socket connect error");
        print(data);
      }
    });

    socket?.on("error", (data){
      if(kDebugMode){
        print("Socket error");
        print(data);
      }
    });

    socket?.on("disconnect", (data){
      if(kDebugMode){
        print("Socket disconnect");
        print(data);
      }
    });

    //Out Socket Emit Listener

    socket?.on("UpdateSocket", (data){
      if(kDebugMode){
        print("UpdateSocket : ------------------");
        print(data);
      }
    });

  }

  Future updateSocketIdApi() async{
    try{
      String racerid = Globs.udValueString("reg_number");
      socket?.emit("UpdateSocket",jsonEncode({'access_token' : "run_$racerid"}));
    }catch(e){
      if(kDebugMode){
        print(e.toString());
      }
    }
  }

}