import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letsruntogether/common/globs.dart';
import 'package:letsruntogether/common/service_call.dart';
import 'package:letsruntogether/models/racer_data.dart';

import '../../common/socket_manager.dart';

part 'webservice_race_detail_event.dart';
part 'webservice_race_detail_state.dart';

class WebserviceRaceDetailBloc extends Bloc<WebserviceRaceDetailEvent, WebserviceRaceDetailState> {


  WebserviceRaceDetailBloc() : super(WebserviceInitial()) {
    on<WebserviceRaceDetailEvent>((event, emit) {

    });
  }

  List<RacerData> racersData = [];

  void setSocketListeners(String raceId){

    raceId = raceId.replaceAll(" ", "");
    raceId = raceId.replaceAll("-", "");
    raceId = raceId.toLowerCase();

    SocketManager.shared.socket?.on("racer_data_updated_$raceId", (data) {
      if (data[KKey.status] == "1") {

        Map<String, dynamic> racerData = data[KKey.payload];

        RacerData rd = RacerData.fromMap2(racerData);

        int resp = updateRacersData(rd);

        if(racersData.length>0){
          racersData.sort((a, b) => b.distanceRunned.compareTo(a.distanceRunned));
          emit(GetRacersDataSuccess(racersData));
        }else{
          emit(GetRacersDataEmpty());
        }

      }
    });
  }

  int updateRacersData(RacerData racerData){

    int index = racersData.indexWhere((map) => map.racer_id == racerData.racer_id);

    if (index != -1) {
      racersData[index] = racerData;
      return 2;
    } else {
      racersData.add(racerData);
      return 1;
    }

  }

}
