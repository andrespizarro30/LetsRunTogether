
import 'dart:async';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

final flutterReactiveBle = FlutterReactiveBle();

StreamSubscription? _scanSubscription;

void scanForDevices() {
  _scanSubscription = flutterReactiveBle.scanForDevices(
    withServices: [], // Add specific service UUIDs, or leave empty for all
    scanMode: ScanMode.balanced,
  ).listen((device) {
    print('Device found: ${device.name} with ID: ${device.id}');
    if (device.name.contains('Galaxy Watch4 Classic (PDDP)')) {
      stopScanning();
      disconnectCharsListenning();
      disconnectDevice();
      connectToDevice(device.id);
    }
  }, onError: (err) {
    print('Error during scanning: $err');
  });

}

void stopScanning() {
  if(_scanSubscription!=null){
    _scanSubscription?.cancel();
    _scanSubscription = null; // Clear the subscription to prevent memory leaks
    print('Scan stopped');
  }
}

void disconnectDevice() {
  if(_swatchConnection!=null){
    _swatchConnection?.cancel(); // Cancel the connection
    _swatchConnection = null; // Clear the subscription
    print('Disconnected from device');
  }
}

StreamSubscription<ConnectionStateUpdate>? _swatchConnection;

void connectToDevice(String deviceId) {
  _swatchConnection = flutterReactiveBle.connectToDevice(
    id: deviceId,
    connectionTimeout: const Duration(seconds: 10),
  ).listen((connectionState) {
    print('Connection state: ${connectionState.connectionState}');
    if (connectionState.connectionState == DeviceConnectionState.connected) {
      //discoverServices(deviceId);
      discoverAndSubscribe(deviceId);
    }
  }, onError: (err) {
    print('Connection error: $err');
  });
}

void discoverServices(String deviceId) async {
  final services = await flutterReactiveBle.discoverServices(deviceId);

  for (var service in services) {
    if(service.serviceId.toString()=="eed6d5cc-c3b2-4d7b-8c6b-7acbf7965bb6"){

    }
    discoverCharacteristics(deviceId, Uuid.parse(service.serviceId.toString()));

    // if (service.serviceId.toString() == "180d") { // Heart Rate Service UUID
    //   for (var characteristic in service.characteristics) {
    //     if (characteristic.characteristicId.toString() == "2a37") { // Heart Rate Measurement UUID
    //       subscribeToHeartRate(deviceId, characteristic.characteristicId);
    //       return;
    //     }
    //   }
    // }
  }
}

void discoverCharacteristics(String deviceId, Uuid serviceId) async {
  final characteristics = await flutterReactiveBle.discoverServices(deviceId);

  for (var service in characteristics) {
    if (service.serviceId == serviceId) {
      print('Found Service: $serviceId');
      for (var characteristic in service.characteristics) {
        print('Characteristic: ${characteristic.characteristicId}');
        subscribeToCharacteristic(deviceId, serviceId, characteristic.characteristicId);
      }
    }
  }
}

void subscribeToCharacteristic(String deviceId, Uuid serviceId, Uuid characteristicId) {
  final characteristic = QualifiedCharacteristic(
    serviceId: serviceId,
    characteristicId: characteristicId,
    deviceId: deviceId,
  );

  flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {
    print('Data from characteristic $characteristicId: $data');

    // Decode heart rate if applicable
    if (data.isNotEmpty) {
      final heartRate = data[1]; // Assuming the 2nd byte contains heart rate
      print('Heart Rate: $heartRate BPM');
    }
  }, onError: (error) {
    print('Error subscribing to characteristic: $error');
  });
}

void subscribeToHeartRate(String deviceId, Uuid characteristicId) {
  flutterReactiveBle.subscribeToCharacteristic(QualifiedCharacteristic(
    serviceId: Uuid.parse("180d"), // Heart Rate Service UUID
    characteristicId: characteristicId,
    deviceId: deviceId,
  )).listen((data) {
    if (data.isNotEmpty) {
      final bpm = data[1]; // Heart rate typically in the second byte
      print('Heart Rate: $bpm BPM');
    }
  }, onError: (err) {
    print('Error subscribing to heart rate: $err');
  });
}

////////new code

void discoverAndSubscribe(String deviceId) async {
  // Discover Services
  final services = await flutterReactiveBle.discoverServices(deviceId);

  for (var service in services) {
    //if (service.serviceId.toString() == "0000180d-0000-1000-8000-00805f9b34fb") {
      print('Found Custom Heart Rate Service');

      for (var characteristic in service.characteristics) {
        print('Subscribing to characteristic: ${characteristic.characteristicId}');
        if (characteristic.isNotifiable) {
          print('This characteristic supports notifications');
          subscribeToCharacteristics(
            deviceId,
            service.serviceId,
            characteristic.characteristicId,
          );
        }
      }
    //}
  }
}

StreamSubscription? _charsSubs;

void disconnectCharsListenning() {
  if(_charsSubs!=null){
    _charsSubs?.cancel(); // Cancel the connection
    _charsSubs = null; // Clear the subscription
    print('Disconnected from characteristics');
  }
}

void subscribeToCharacteristics(String deviceId, Uuid serviceId, Uuid characteristicId) {
  final characteristic = QualifiedCharacteristic(
    serviceId: serviceId,
    characteristicId: characteristicId,
    deviceId: deviceId,
  );

  _charsSubs = flutterReactiveBle.subscribeToCharacteristic(characteristic).listen((data) {

    print('Data from characteristic $characteristicId: $data');

    // Example: Assuming heart rate is in the 2nd byte
    if (data.isNotEmpty) {
      final heartRate = data[1];
      print('Heart Rate: $heartRate BPM');
    }
  }, onError: (error) {
    print('Error subscribing to characteristic: $error');
  },
  onDone: (){
    print('Done');
  }
  );

  _charsSubs!.onData((data) {
    print('Data from characteristic $characteristicId: $data');

    // Example: Assuming heart rate is in the 2nd byte
    if (data.isNotEmpty) {
      final heartRate = data[1];
      print('Heart Rate: $heartRate BPM');
    }
  });

  _charsSubs!.onDone(() {

  });

  _charsSubs!.onError((handleError){

  });

}
///////new code

void getPairedDevices() async {
  final List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();
  for (var device in devices) {
    print('Paired Device: ${device.name}, Address: ${device.address}');
    if (device.name!.contains("Galaxy Watch4 Classic (PDDP")) {
      stopScanning();
      disconnectCharsListenning();
      disconnectDevice();
      scanForDevices();
      //connectToDevice(device.address);
      //discoverAndSubscribe(device.address);
    }
  }
}

Future<void> requestPermissions() async {
  final status = await Permission.bluetoothScan.request();
  final bluetoothConnectStatus = await Permission.bluetoothConnect.request();
  final bluetoothScanStatus = await Permission.bluetoothScan.request();
  final locationStatus = await Permission.location.request();

  if (status.isGranted && bluetoothConnectStatus.isGranted && bluetoothScanStatus.isGranted && locationStatus.isGranted) {
    getPairedDevices();
  } else {
    print("Permissions denied");
  }
}