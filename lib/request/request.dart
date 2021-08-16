import 'package:dio/dio.dart';
import 'package:hive/hive.dart';
import '../global.dart';


class DataSource{
  late Map<String, dynamic> aarg;
  final dynamic arg;
  final String url;
  late String source;
  late dynamic secureData = requestToken;
  Dio dio = Dio();
  late Response response;

  DataSource({required this.url, required this.arg}){
    if (url.startsWith('/')){
      source = url.substring(1);
    }else{
      source = url;
    }
    aarg = arg;
  }

  update(data, {bool? replace=true}) async {
    
    print("updating data in mobile backup");
    try{
      Box _data;
      
      _data = await Hive.openBox(source.split('/').last);
      print(_data.path);
      if (replace!){
        if (_data.isNotEmpty){
          for (var i= 0; i < _data.length; i++){
            await _data.deleteAt(i);
            
          }
           print("loop setting");
        }
      }
      
      await _data.addAll((data is List) ? data : [data]);
      print('mobile backup data: ${_data.values.length}');
    }catch(err){
      print('Error: $err');
    }
  }

  get(_err) async{
    print("getting data from save");
    if (await Hive.boxExists(source)){
      await Hive.openBox(source);
      print(Hive.box(source).getAt(0));
      return Hive.box(source).getAt(0);
    }else {
      throw Exception(_err);
    }
  }

  destroy() async{
    print("destroying data from mobile backup");
    if (await Hive.boxExists(source)){
      await Hive.deleteBoxFromDisk(source);
    }else {
      //'we rule';
    }
  }

  request() async{
    if (!aarg.containsKey('userID')){
      print("requesting data from backend");
        aarg.addAll({'userID': secureData['id']});
    }
    //print("requesting data from backend");
    
  }


}