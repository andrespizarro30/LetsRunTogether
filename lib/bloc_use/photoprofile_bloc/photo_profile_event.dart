part of 'photo_profile_bloc.dart';

abstract class PhotoProfileEvent {}

class GetCameraImage extends PhotoProfileEvent {}

class GetGalleryImage extends PhotoProfileEvent {}
