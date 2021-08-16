

import 'package:kinco/global.dart';

class PostModel {
  final videoUrl;
  
  PostModel({required this.videoUrl});


  factory PostModel.fromJson(dynamic _data){
    return PostModel(
      videoUrl: httpHost(_data['url'])
    );
  }

  toJson() {
    return {
      'videoUrl': videoUrl
    };
  }
}
