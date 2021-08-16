import 'package:dio/dio.dart';

import '../global.dart';
import './request.dart';

class DataRequestData extends DataSource {
  final url;
  final Map<String, dynamic> arg;

  DataRequestData({required this.url, required this.arg,}): super(url: url, arg: arg);

  @override
  request() async {
    super.request();
    // try{
      print('ID is $secureData');
      response = await dio.post(
        httpHost(source),
        options: Options(
          headers: {
            'authentication': secureData['token'],
          }
        ),
        data: aarg,
      ).catchError((err){
        print(err);
        throw err;
      });

      
      if (response.data is Map && response.data['errorMessage'] != null){
        print(response.data['message']);
      //   dynamic _data = await get(response.data);
      //   return {"type": 'saved', "data": _data};
      }
      update(response.data);
      return {"type": 'cloud', "data": response.data};
    // }catch(err){
    //   print(err);
    //   print("Unable to get data from backend");
    //   dynamic _saveData = await get(err);
    //   print(_saveData);
    //   return {"type": 'saved', "data": _saveData};
    // }
  }
}