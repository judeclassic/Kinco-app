import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:kinco/global.dart';
import 'package:kinco/views/routes/media_page.dart';
import 'package:kinco/views/routes/home_page.dart';
import 'package:kinco/views/routes/login_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rive/rive.dart';

main() => runApp(MainApp());

class MainApp extends StatefulWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  _MainAppState createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData.dark().copyWith(
        //backgroundColor: Color.fromRGBO(25, 0, 26, 0.9),
        //scaffoldBackgroundColor: Color.fromRGBO(45, 0, 48, 0.9),
      ),
      theme: ThemeData.light().copyWith(
        primaryColorLight: Colors.blueGrey
      ),
      initialRoute: InitialPage().route,
      routes: {
        InitialPage().route: (context)=> InitialPage(),
        HomePage().route: (context)=> HomePage(),
        LoginPage().route: (context)=> LoginPage(),
        MediaPage().route: (context)=> MediaPage(),
      },
    );
  }
}

class InitialPage extends StatefulWidget  {
  final String route = '/initialPage';
  const InitialPage({Key? key}) : super(key: key);

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  bool _isError = false;

  _initialCode() async{
    Directory path = await getApplicationSupportDirectory();
    Hive.init(path.path);
    
    if (await Permission.storage.request().isGranted && await Permission.camera.request().isGranted) {
      if (await Hive.boxExists('/token')){
        print("one: User logged moving to homePage");
        Box box = await Hive.openBox('/token');
        print(box.values.length);
        requestToken = box.values.single;
        print(requestToken);
        Navigator.of(context).pushReplacementNamed(HomePage().route);
        return;
      }else{
        print("two: User not logged in moving to loginPage");
        Navigator.of(context).pushReplacementNamed(LoginPage().route);
        return;
      }
    }else{
      print("three: Required Permission not granted");
      setState(() {
        _isError = true;
      });
      return;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initialCode();
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: -80,
            child: Container(
              height: _height + 80,
              width: _width,
              child: RiveAnimation.asset(
                "asset/animations/login_screen.riv",
                fit: BoxFit.fitHeight,
                alignment: Alignment.topCenter,
              ),
            ),
          ),
          Positioned(
            child: Container(
              height: _height,
              width: _width,
              child: Center(
                child: Text(
                  _isError ? "App Cannot Proceed without Necessary Permission" : "",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              )
            ),
          ),
        ]
      ),
    );
  }
}


