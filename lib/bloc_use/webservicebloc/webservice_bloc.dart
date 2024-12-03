import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:letsruntogether/common/globs.dart';
import 'package:letsruntogether/common/service_call.dart';

import '../../common/socket_manager.dart';

part 'webservice_event.dart';
part 'webservice_state.dart';

class WebserviceBloc extends Bloc<WebserviceEvent, WebserviceState> {


  WebserviceBloc() : super(WebserviceInitial()) {
    on<WebserviceEvent>((event, emit) {
      if(event is GetRacesEv){
        getRaces();
      }
    });
  }

  void getRaces(){

    emit(GetRacesLoading());
    try{
      ServiceCall.post(
          {},
          SVKey.svGetRaces,
          withSuccess:(responseObj)async{
            if((responseObj[KKey.status] as String? ?? "")=="1"){
              var payload = responseObj[KKey.payload] as List ?? [];
              racesData = payload;
              emit(GetRacesSuccess(payload));
            }else{
              emit(GetRacesError(responseObj[KKey.message] as String));
            }
          },
          failure: (err) async{
            emit(GetRacesError(err.toString()));
          }
      );
    }catch(e){
      emit(GetRacesError(e.toString()));
    }

  }

  List racesData = [];

  void filterRacesData(String query){

    List filteredRaces = [];

    if(query.isNotEmpty){
      // Filter the races based on the race_id (case insensitive)
      filteredRaces = racesData.where((race) {
        return race["race_id"].toLowerCase().contains(query);
      }).toList();
    }else{
      filteredRaces = racesData;
    }

    emit(GetRacesSuccess(filteredRaces));

  }

}
