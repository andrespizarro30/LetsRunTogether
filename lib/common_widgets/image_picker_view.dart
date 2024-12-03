import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:letsruntogether/bloc_use/photoprofile_bloc/photo_profile_bloc.dart';
import 'package:letsruntogether/common/common_extensions.dart';
import 'package:path_provider/path_provider.dart';

class ImagePickerView extends StatefulWidget {

  const ImagePickerView({super.key});

  @override
  State<ImagePickerView> createState() => _ImagePickerViewState();
}

class _ImagePickerViewState extends State<ImagePickerView> {

  final picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    final routeRequest = BlocProvider.of<PhotoProfileBloc>(context);

    routeRequest.stream.listen((state) {
      if (state is GetImageProfileSuccess) {
        context.pop();
      }
    });

  }

  @override
  Widget build(BuildContext context) {

    Future getImageCamera() async{
      try{
        final pickedFile = await picker.pickImage(source: ImageSource.camera);
        if(pickedFile!=null){
          String imagePath = await reduceImageFileSize(pickedFile);
          context.pop();
        }
      }catch(e){
        debugPrint(e.toString());
      }
    }

    Future getImageGallery() async{
      try{
        final pickedFile = await picker.pickImage(source: ImageSource.gallery);
        if(pickedFile!=null){
          String imagePath = await reduceImageFileSize(pickedFile);
          context.pop();
        }
      }catch(e){
        debugPrint(e.toString());
      }
    }

    return Container(
      width: context.width * 0.9,
      height: context.heigth * 0.5,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const[
          BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: 4)
        ]
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Foto perfil",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: Colors.black26
            ),
          ),
          SizedBox(height: context.width * 0.04,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: TextButton(
                  onPressed: (){
                    //getImageCamera();
                    BlocProvider.of<PhotoProfileBloc>(context).add(GetCameraImage());
                  },
                  child: Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: Colors.black26,
                  ),
                )
              ),
              Expanded(
                  child: TextButton(
                    onPressed: (){
                      //getImageGallery();
                      BlocProvider.of<PhotoProfileBloc>(context).add(GetGalleryImage());
                    },
                    child: Icon(
                      Icons.image,
                      size: 100,
                      color: Colors.black26,
                    ),
                  )
              )
            ],
          ),
          SizedBox(height: context.width * 0.04,),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  child: Text(
                    "Cámara",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 17
                    ),
                  )
              ),
              Expanded(
                  child: Text(
                    "Galería",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black26,
                        fontSize: 17
                    ),
                  )
              ),
            ],
          ),
          SizedBox(height: context.width * 0.04,),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: (){
                  context.pop();
                },
                child: Text(
                  "Cerrar",
                  style: TextStyle(
                    color: Colors.black26,
                    fontSize: 20,
                    fontWeight: FontWeight.w600
                  ),
                )
              )
            ],
          )
        ],
      ),
    );
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
