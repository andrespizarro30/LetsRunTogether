import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';

part 'photo_profile_event.dart';
part 'photo_profile_state.dart';

class PhotoProfileBloc extends Bloc<PhotoProfileEvent, PhotoProfileState> {

  PhotoProfileBloc() : super(PhotoProfileInitial()) {
    on<PhotoProfileEvent>((event, emit) {
      if(event is GetCameraImage){
        getImageCamera();
      }else
      if(event is GetGalleryImage){
        getImageGallery();
      }
    });
  }

  final picker = ImagePicker();

  Future getImageCamera() async{
    try{
      final pickedFile = await picker.pickImage(source: ImageSource.camera);
      if(pickedFile!=null){
        String imagePath = await reduceImageFileSize(pickedFile);
        File imageFile = File(imagePath);
        emit(GetImageProfileSuccess(imageFile));
      }
    }catch(e){

    }
  }

  Future getImageGallery() async{
    try{
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if(pickedFile!=null){
        String imagePath = await reduceImageFileSize(pickedFile);
        File imageFile = File(imagePath);
        emit(GetImageProfileSuccess(imageFile));
      }
    }catch(e){

    }
  }

  Future<String> reduceImageFileSize(XFile imageFile) async{

    final bytes = await imageFile.readAsBytes();

    final compressedBytes = await FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 200,
      minHeight: 200,
      quality: 30,
    );

    final directory = await getTemporaryDirectory();
    final compressedImageFile = File('${directory.path}/compressed_image.jpg');
    await compressedImageFile.writeAsBytes(compressedBytes);

    return compressedImageFile.path;

  }

}
