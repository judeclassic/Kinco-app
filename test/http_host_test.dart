import 'package:flutter_test/flutter_test.dart';
import 'package:kinco/global.dart';

void main() {
  test("return full url", (){
    String httpString = httpHost("login");
    expect(httpString, "http://10.0.2.2:8080/login");
  });
}