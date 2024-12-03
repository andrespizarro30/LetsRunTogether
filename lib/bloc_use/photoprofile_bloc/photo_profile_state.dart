part of 'photo_profile_bloc.dart';

abstract class PhotoProfileState {}

final class PhotoProfileInitial extends PhotoProfileState {}

class GetImageProfileSuccess extends PhotoProfileState {
  File imageFile;
  GetImageProfileSuccess(this.imageFile);
}
