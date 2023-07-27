import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class PostStoryModel{
  XFile? file;
  bool memory = false;
  void switcher(){
    memory = !memory;
  }
  void dispose(){

  }
}