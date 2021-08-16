
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kinco/global.dart';
import 'package:kinco/models/post.dart';
import 'package:kinco/request/data_request.dart';
import 'package:kinco/views/widgets/list_tile.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rive/rive.dart' as rive;
import 'package:sizer/sizer.dart';


class HomePage extends StatefulWidget {
  final String route = "/homePage";
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  GlobalKey<ScaffoldState> _scaffoldGlobalKey = GlobalKey();
  int _initialTab = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, _, __) {
        return Scaffold(
          key: _scaffoldGlobalKey,
          body: Container(
            child: DefaultTabController(
              initialIndex: _initialTab,
              length: 3,
              child: TabBarView(
                children: [
                  MainPage(),
                  SearchPage(),
                  ProfilePage()
                ],
              ),
            ),
          )
        );
      }
    );
  }
}



class SearchPage extends StatefulWidget {
  const SearchPage({ Key? key }) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List contentTiles  = [];
  String _search = '';

  _searchContent(String text) async{
    print(text);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          primary: true,
          floating: true,
          snap: true,
          title: Container(
            child: TextField(
              controller: searchController,
              onSubmitted: (text){
                _searchContent(text);
              },
              style: TextStyle(
                fontSize: 18,
              ),
            ),
          ),
          elevation: 0,
        ),
        SliverAnimatedList(
          initialItemCount: 5,
          itemBuilder: (context, _, __)=> ContentTile(),
        )
      ],
    );
  }
}




class MainPage extends StatefulWidget {
  const MainPage({ Key? key }) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int defaultLength = 4;

  void _createPost() {
    Navigator.of(context).pushNamed('/createPage');
  }

  Future<void> _pullToRefresh() async{
    print("refreshing");
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    double _h = MediaQuery.of(context).size.height;
    double _w = MediaQuery.of(context).size.width;

    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            primary: true,
            floating: true,
            snap: true,
            expandedHeight: _h/10,
            flexibleSpace: Container(
              height: _h/5,
              width: _w,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: rive.RiveAnimation.asset(
                      "asset/animations/loader.riv",
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                  Positioned(
                    top: _h/10,
                    right: _h/20,
                    child: InkWell(
                      onTap: (){
                        _createPost();
    
                      },
                      child: Opacity(
                        opacity: 0.6,
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
                              "Post",
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
    
            ),
          ),
    
          FutureBuilder(
            future: DataRequestData(url: '/user/content/requestPosts', arg: {}).request(),
            builder: (context, AsyncSnapshot snapshot){
              if (snapshot.hasData){
                List _data = (snapshot.data as dynamic)['data'];
                
                print(_data);
                // return SliverFillRemaining();
                return SliverAnimatedList(
                  initialItemCount: _data.length,
                  itemBuilder: (context, index, bc){
                    PostModel data = PostModel.fromJson(_data[(_data.length - index - 1)]);
                    return ContentTile(
                      data: data,
                    );
                  }
                );
              }else{
                return SliverAnimatedList(
                  initialItemCount: 4,
                  itemBuilder: (context, _, __)=> ContentTile()
                );
              }
            }
          )
        ],
      ),
    );
  }
}




class ProfilePage extends StatefulWidget {
  const ProfilePage({ Key? key }) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late DataRequestData _userDataSource;
  ImagePicker _image = ImagePicker();
  Widget _profileImage = SizedBox();
  Directory? _fileDirectory;
  late File _file;

  _changeProfileImage() async{
    print(_fileDirectory!.path);
    XFile? photo = await _image.pickImage(source: ImageSource.gallery);
    await photo!.saveTo(_file.path);
    setState(() {
      
    });
  }

  getData() async{Directory!
    _fileDirectory = await getExternalStorageDirectory();
    _userDataSource = DataRequestData(url: '/user', arg: {});
    _file = File('${_fileDirectory!.path}/file.png');
    if (await _file.exists()){
      _profileImage = Image.file(_file);
    }
    return _userDataSource.request();
  }

  void _logout() async {
    await DataRequestData(url: '/token', arg: {}).destroy();
    await DataRequestData(url: '/user/login', arg: {}).destroy();
    Navigator.of(context).pushReplacementNamed('/loginPage');
  }

  @override
  Widget build(BuildContext context) {
    

    return Sizer(
      builder: (context, _, __) {
        return FutureBuilder(
          future: getData(),
          builder: (context, _snapshot) {
            if (_snapshot.hasData){
              dynamic _data = (_snapshot.data  as dynamic)['data'];
              return SingleChildScrollView(
                child: Container(
                  height: 150.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).backgroundColor,
                        Theme.of(context).scaffoldBackgroundColor,
                      ]
                    )
                  ),
                  
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5.h,
                        left: 5.w,
                        child: Container(
                          height: 90.w,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey,//Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(5.w)),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).primaryColorLight),
                              BoxShadow(color: Theme.of(context).primaryColor),
                              BoxShadow(color: Theme.of(context).primaryColorDark),
                            ]
                          ),
                        ),
                      ),

                      Positioned(
                        top: 45.w + 5.h - 100,
                        left: 50.w - 100,
                        child: Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.red,//Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(100)),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).primaryColorLight),
                              BoxShadow(color: Theme.of(context).primaryColor),
                              BoxShadow(color: Theme.of(context).primaryColorDark),
                            ]
                          ),
                          child: _profileImage,
                        ),
                      ),

                      Positioned(
                        top: 45.w + 5.h + 50,
                        left: 50.w + 50,
                        child: InkWell(
                          onTap: (){
                            _changeProfileImage();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              color: Colors.deepPurple,//Theme.of(context).backgroundColor,
                              borderRadius: BorderRadius.all(Radius.circular(25)),
                              boxShadow: [
                                BoxShadow(color: Theme.of(context).primaryColorLight),
                                BoxShadow(color: Theme.of(context).primaryColor),
                                BoxShadow(color: Theme.of(context).primaryColorDark),
                              ]
                            ),
                            child: Center(
                              child: Icon(
                                Icons.camera_alt
                              ),
                            ),
                          ),
                        ),
                      ),
                                
                      Positioned(
                        top: 5.h,
                        right: 5.h,
                        child: InkWell(
                          onTap: (){
                            _logout();
                                
                          },
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 100,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Center(
                                child: Text(
                                  "LogOut",
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
                        top: 105.w,
                        left: 2.5.w,
                        child: Opacity(
                          opacity: 0.05,
                          child: Container(
                            height: 30.w,
                            width: 95.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                            ),
                          ),
                        )
                      ),

                      Positioned(
                        top: 105.w,
                        left: 7.5.w,
                        child: Text(
                          '${capitalize(_data["firstname"])} ${capitalize(_data["surname"])}',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 115.w,
                        left: 7.5.w,
                        child: Text(
                          '@${capitalize(_data["username"])}',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 125.w,
                        left: 7.5.w,
                        child: Text(
                          '${capitalize(_data["email"])}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 160.w,
                        left: 2.5.w,
                        child: Container(
                          width: 95.w,
                          height: 50.w,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(5, (index) => Container(
                                margin: EdgeInsets.only(right: 2.5.w),
                                height: 50.w,
                                width: 50.w,
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                ),
                              ),)
                            )
                          ),
                        ),
                      ),       
                    ]
                  ),
                ),
              );
            }else{

              return SingleChildScrollView(
                child: Container(
                  height: 150.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).backgroundColor,
                    gradient: LinearGradient(
                      begin: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).backgroundColor,
                        Theme.of(context).scaffoldBackgroundColor,
                      ]
                    )
                  ),
                  
                  child: Stack(
                    children: [
                      Positioned(
                        top: 5.h,
                        left: 5.w,
                        child: Container(
                          height: 90.w,
                          width: 90.w,
                          decoration: BoxDecoration(
                            color: Colors.red,//Theme.of(context).backgroundColor,
                            borderRadius: BorderRadius.all(Radius.circular(5.w)),
                            boxShadow: [
                              BoxShadow(color: Theme.of(context).primaryColorLight),
                              BoxShadow(color: Theme.of(context).primaryColor),
                              BoxShadow(color: Theme.of(context).primaryColorDark),
                            ]
                          )
                        ),
                      ),
                                
                      Positioned(
                        top: 5.h,
                        right: 5.h,
                        child: InkWell(
                          onTap: (){
                            _logout();
                                
                          },
                          child: Opacity(
                            opacity: 0.8,
                            child: Container(
                              padding: EdgeInsets.all(5),
                              width: 100,
                              height: 40,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).backgroundColor,
                                  borderRadius: BorderRadius.all(Radius.circular(10))
                              ),
                              child: Center(
                                child: Text(
                                  "LogOut",
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
                        top: 105.w,
                        left: 2.5.w,
                        child: Opacity(
                          opacity: 0.05,
                          child: Container(
                            height: 30.w,
                            width: 95.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.all(Radius.circular(5.w))
                            ),
                          ),
                        )
                      ),

                      Positioned(
                        top: 105.w,
                        left: 7.5.w,
                        child: Text(
                          'LALALALALA',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 115.w,
                        left: 7.5.w,
                        child: Text(
                          'LALALALALA',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 125.w,
                        left: 7.5.w,
                        child: Text(
                          'LALALALALA',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontFamily: 'serif',
                            letterSpacing: 2.sp
                          ),
                        ),
                      ),

                      Positioned(
                        top: 160.w,
                        left: 2.5.w,
                        child: Container(
                          width: 95.w,
                          height: 50.w,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: List.generate(5, (index) => Container(
                                margin: EdgeInsets.only(right: 2.5.w),
                                height: 50.w,
                                width: 50.w,
                                decoration: BoxDecoration(
                                  color: Colors.amberAccent,
                                  borderRadius: BorderRadius.all(Radius.circular(5.w)),
                                ),
                              ),)
                            )
                          ),
                        ),
                      ),       
                    ]
                  ),
                ),
              );
            }
    
          }
        );
      }
    );
  }
}
