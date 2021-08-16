import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:kinco/global.dart';
import 'package:kinco/request/data_request.dart';
import 'package:rive/rive.dart';
import 'package:sizer/sizer.dart';

class LoginPage extends StatefulWidget {
  final String route = '/loginPage';
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  GlobalKey<FormState> _formKey = GlobalKey();
  SMITrigger? _riveSuccessTrigger;
  SMITrigger? _riveFailureTrigger;
  late DataRequestData _dataSource;
  late AnimationController _loginController;
  late AnimationController _signUpController;
  late Animation _animatedHeight;
  late Animation _animatedSignUpHeight;
  late Animation _animatedRadius;
  late Animation _animatedSignUpRadius;
  Dio _dio = Dio();
  
  bool _signUpNext = false;
  bool _isLogin = true;

  TextEditingController _firstName = TextEditingController();
  TextEditingController _surName = TextEditingController();
  TextEditingController _userName = TextEditingController();

  TextEditingController _email = TextEditingController();
  TextEditingController _emailPassCode = TextEditingController();
  TextEditingController _password = TextEditingController();
  TextEditingController _verifyPassword = TextEditingController();

  void _login(context) async{

    if (_isLogin){
      // Navigator.pushReplacementNamed(context, '/homePage');
      if (_email.text.isEmpty || _password.text.isEmpty){
        print("cant use empty field");
        return null;
      }
      await _dio.post(
        httpHost('/user/login/'),
        data: {
          "email": _email.text.toLowerCase(),
          "password": _password.text
        }

      ).then((_response) async{
        
          _globalKey.currentState!.showBottomSheet((context) => Container(
          child: Text("Login Successful"),
        ));

        _dataSource = DataRequestData(url: '/token', arg: {});
        _dataSource.update(_response.data);
        requestToken = _response.data;
        
        await Future.delayed(
          Duration(milliseconds: 5000),
          (){
            _riveSuccessTrigger?.fire();
          }
        );
        Navigator.pushReplacementNamed(context, '/homePage');

      }).onError((DioError error, stackTrace) async{

        _riveFailureTrigger?.fire();
        print(error.response);

      }
      ).catchError((err){

        _riveFailureTrigger?.fire();
        print("Error: ${err.message}");

      });

    }else{
      setState(() {
        _signUpNext = false;
        _isLogin = true;
      });
      _signUpController.reverse();
      _loginController.reverse();
    }
  }

  void _signUpBack(){
    setState(() {
      _signUpNext = false;
    });
    _signUpController.reverse();
  }

  void _verifyEmail() async{

  }

  void _signUp() async{
    if (_isLogin){
      setState(() {
        _isLogin = false;
        _signUpNext = false;
      });

      _loginController.forward();
    }else {
      if(!_signUpNext){
        setState(() {
          _signUpNext = true;
          _riveSuccessTrigger?.fire();
        });
        _signUpController.forward();
      }else {
        try{
          Response _response = await _dio.post(httpHost('/user/signup'), data: {
            "firstName": _firstName.text.toLowerCase(),
            "surName": _surName.text.toLowerCase(),
            "userName": _userName.text.toLowerCase(),
            "email": _email.text.toLowerCase(),
            "password": _password.text
          });

          if (_response.statusCode == 200){
            _globalKey.currentState!.showBottomSheet((context) => Container(
              child: Text("Login Successful"),
            ));

            _riveSuccessTrigger?.fire();
          }else{

          }
        }catch(err){
          print(err);
          _riveFailureTrigger?.fire();
        }

      }
    }

  }

  void _onRiveAnimatedInit(Artboard _artBoard) {
    final _riveStateController = StateMachineController.fromArtboard(
      _artBoard,
      'State Machine 1',
      onStateChange: _changeRiveAnimationState,
    );
    _artBoard.addController(_riveStateController!);
    _riveFailureTrigger = _riveStateController.findInput<bool>('Incorrect') as SMITrigger;
    _riveSuccessTrigger = _riveStateController.findInput<bool>('Correct') as SMITrigger;
  }
  
  _changeRiveAnimationState(String stateMachineName, String stateName) {
    return "";
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _loginController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this
    );

    _animatedHeight = Tween<double>(
      begin: 0,
      end: 10).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: Curves.bounceInOut
      )
    );

    _signUpController = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this
    );

    _animatedSignUpHeight = Tween<double>(
      begin: 0,
      end: 10).animate(
      CurvedAnimation(
        parent: _signUpController,
        curve: Curves.bounceInOut
      )
    );

    _animatedRadius = Tween<Radius>(
      begin: Radius.circular(10),
      end: Radius.circular(0)).animate(
      CurvedAnimation(
        parent: _loginController,
        curve: Curves.bounceInOut
      )
    );

    _animatedSignUpRadius = Tween<Radius>(
      begin: Radius.circular(0),
      end: Radius.circular(10)).animate(
      CurvedAnimation(
        parent: _signUpController,
        curve: Curves.bounceInOut
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    double _width = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _globalKey,
      resizeToAvoidBottomInset: false,
      body: Sizer(
        builder: (context, _, __) {
          return AnimatedBuilder(
            animation: _loginController,
            builder: (context, _) {
              return AnimatedBuilder(
                animation: _signUpController,
                builder: (context, __) {
                  return Form(
                    key: _formKey,
                    child: Stack(
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
                              stateMachines: ['State Machine 1'],
                              onInit: _onRiveAnimatedInit,
                            ),
                          ),
                        ),

                        Positioned(
                          top: 35.h - _animatedHeight.value,
                          left: (100.w-300)/2,
                          child: Opacity(
                            opacity: (_signUpNext ?  (0.09 * (10 - _animatedSignUpHeight.value)) : (0.09 *_animatedHeight.value)),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 300,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(0))
                              ),
                              child: TextFormField(
                                controller: _firstName,
                                decoration: InputDecoration(
                                    hintText: "first name",
                                    hintStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  prefixIcon: Icon(Icons.account_circle)
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ),
                          ),
                        ),

                        Positioned(
                          top: (34.h) + (0.65.h * _animatedHeight.value),
                          left: (_width - 300)/2,
                          child: Opacity(
                            opacity: _signUpNext ? 0.09 * (10 - _animatedSignUpHeight.value) : (0.09 *_animatedHeight.value),
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 300,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(0))
                              ),
                              child: TextFormField(
                                controller: _surName,
                                decoration: InputDecoration(
                                    hintText: "Surname",
                                    hintStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  prefixIcon: Icon(Icons.account_circle)
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ),
                          ),
                        ),

                        Positioned(
                          top: (1.h * _animatedSignUpHeight.value),
                          left: (_width - 350)/2,
                          child: InkWell(
                            onTap: (){
                              _verifyEmail();
                            },
                            child: Opacity(
                              opacity: (0.09 * (_animatedSignUpHeight.value)),
                              child: IconButton(
                                icon: Icon(Icons.arrow_back_ios),
                                iconSize: 30,
                                onPressed: (){
                                  _signUpBack();
                                },
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 15.h + (2.h * _animatedSignUpHeight.value) + (_animatedSignUpHeight.value),
                          left: (_width - 300)/2,
                          child: Opacity(
                            opacity: (0.09 * (_animatedSignUpHeight.value)),
                            child: Container(
                                padding: EdgeInsets.all(5),
                                width: 300,
                                height: 55,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(10), bottom: Radius.circular(10))
                                ),
                                child: TextFormField(
                                  controller: _emailPassCode,
                                  decoration: InputDecoration(
                                    hintText: "verification code",
                                    hintStyle: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    prefixIcon: Icon(Icons.password_sharp)
                                  ),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                )
                            ),
                          ),
                        ),

                        Positioned(
                          top: 15.h + (2.h * _animatedSignUpHeight.value) + (65 + _animatedSignUpHeight.value),
                          left: (_width - 300)/2,
                          child: InkWell(
                            onTap: (){
                              _verifyEmail();
                            },
                            child: Opacity(
                              opacity: (0.09 * (_animatedSignUpHeight.value)),
                              child: Container(
                                padding: EdgeInsets.all(5),
                                width: 100,
                                height: 40,
                                decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColorLight,
                                    borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Center(
                                  child: Text(
                                    "Verify",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 33.h + (11 * _animatedHeight.value) + (7 * _animatedSignUpHeight.value),
                          left: (_width - 300)/2,
                          child: Opacity(
                            opacity: 0.9,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 300,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.vertical(top: _signUpNext ? _animatedSignUpRadius.value : _animatedRadius.value, bottom: Radius.circular(0)),
                              ),
                              child: TextFormField(
                                controller: _isLogin ? _email: _signUpNext ? _password: _userName,
                                decoration: InputDecoration(
                                  hintText: _isLogin ? "email@mail.com": _signUpNext ? "password": "username",
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(_isLogin ? Icons.email : _signUpNext ? Icons.password : Icons.account_box)
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),



                        Positioned(
                          top: 40.h + (11 * _animatedHeight.value) + (7 * _animatedSignUpHeight.value),
                          left: 12.w,
                          child: Opacity(
                            opacity: 0.9,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 76.w,
                              height: 6.h,
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColorLight,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(10))
                              ),
                              child: TextFormField(
                                controller: _isLogin ? _password : _signUpNext ? _verifyPassword: _email,
                                decoration: InputDecoration(
                                  hintText: _isLogin ? "*******" : _signUpNext ? "password" : "email",
                                  hintStyle: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  prefixIcon: Icon(_isLogin ? Icons.password : _signUpNext ? Icons.password: Icons.email)
                                ),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w400,
                                ),
                              )
                            ),
                          ),
                        ),

                        Positioned(
                          top: 60.h + (3 * _animatedHeight.value).h,
                          left: (_width - 250)/2,
                          child: InkWell(
                            onTap: (){
                              _login(context);
                            },
                            child: Opacity(
                              opacity: 0.9,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                width: 250,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Center(
                                  child: Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          top: 90.h - (2.h * _animatedHeight.value) + (0.9.h * _animatedSignUpHeight.value),
                          left: (_width - 200)/2,
                          child: InkWell(
                            onTap: (){
                              _signUp();
                            },
                            child: Opacity(
                              opacity: 0.9,
                              child: Container(
                                padding: EdgeInsets.all(5),
                                width: 200,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColorLight,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                                ),
                                child: Center(
                                  child: Text(
                                    _isLogin || _signUpNext? "Sign Up": "Next",
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              );
            }
          );
        }
      ),
    );
  }
}
