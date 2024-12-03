part of 'webservice_bloc.dart';

abstract class  WebserviceState{}

final class WebserviceInitial extends WebserviceState {}

class GetRacesSuccess extends WebserviceState {
  List racesData;
  GetRacesSuccess(this.racesData);
}

class GetRacesLoading extends WebserviceState {}

class GetRacesError extends WebserviceState {
  final String error;
  GetRacesError(this.error);
}


