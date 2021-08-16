import 'package:dio/dio.dart';
import 'package:kinco/global.dart';

import './request.dart';

class FileRequestData extends DataSource {
  final url;
  final Map<String, dynamic> files, arg;

  FileRequestData({required this.url, required this.arg, required this.files}): super(url: url, arg: arg);
  
  @override
  request() async {
    super.request();
    try{
      print('ID is $secureData');

      for (var file in files.entries){
        aarg.addAll({
          file.key: await MultipartFile.fromFile(
            file.value,
            filename: file.value.split('/').last.replaceAll(' ', '_')
          )
        });
      }

      FormData formData = FormData.fromMap(aarg);
      
      response = await dio.post(
        httpHost(source),
        options: Options(
          headers: {
            'authentication': secureData['token'],
          }
        ),
        data: formData,
      );

      print(response);
      //return response.data;
    }catch(err){
      print(err);
      
    }
  }
}