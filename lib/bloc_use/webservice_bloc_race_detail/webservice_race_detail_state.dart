part of 'webservice_race_detail_bloc.dart';

abstract class  WebserviceRaceDetailState{}

final class WebserviceInitial extends WebserviceRaceDetailState {}

class GetRacersDataSuccess extends WebserviceRaceDetailState {
  List racersData;
  GetRacersDataSuccess(this.racersData);
}

class GetRacersDataLoading extends WebserviceRaceDetailState {}

class GetRacersDataEmpty extends WebserviceRaceDetailState {}

class GetRacersDataError extends WebserviceRaceDetailState {
  final String error;
  GetRacersDataError(this.error);
}

