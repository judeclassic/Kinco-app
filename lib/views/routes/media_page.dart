import 'dart:io';

import 'package:camerawesome/camerawesome_plugin.dart';
import 'package:flutter/material.dart';
import 'package:kinco/request/file_request.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sizer/sizer.dart';

class MediaPage extends StatefulWidget {
  final String route = '/createPage';
  const MediaPage({Key? key}) : super(key: key);

  @override
  _MediaPageState createState() => _MediaPageState();
}



class _MediaPageState extends State<MediaPage> with TickerProviderStateMixin{
  VideoController _videoController = VideoController();
  PictureController _pictureController = PictureController();

  ValueNotifier<CaptureModes> _captureMode = ValueNotifier(CaptureModes.PHOTO);
  ValueNotifier<Size> _photoSize = ValueNotifier(Size.fromHeight(500));
  ValueNotifier<CameraFlashes> _switchFlash = ValueNotifier(CameraFlashes.ON);
  ValueNotifier<Sensors> _sensor = ValueNotifier(Sensors.BACK);
  ValueNotifier<bool>? _enableAudio = ValueNotifier(false);
  late String _newPath;
  bool _isFront = true;
  bool _isRecording = false;

  late AnimationController _controller;
  //late AnimationController _timerController;
  late Animation _scalerAnimation;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this
    );
    _scalerAnimation = Tween<double>(begin: 1, end: 1.5).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
  }

  _toggleLight() async{
    setState(() {
      _switchFlash = ValueNotifier(CameraFlashes.ALWAYS);
    });
  }

  _toggleCamera() async{
    if (_isFront){
      _sensor = ValueNotifier(Sensors.BACK);
      setState(() {});
    }else{
      _sensor = ValueNotifier(Sensors.FRONT);
      setState(() {});
    }
    _isFront = !_isFront;
  }

// FUNCTION FOR BUTTON CLICKER//
  Future<void> _takeShot() async{
    List<Directory>? _fileDirectory = await (Platform.isAndroid ? getExternalStorageDirectories() : getExternalCacheDirectories());
    String _fileUrl = _fileDirectory![0].path;
    Directory _newDirectory = await Directory('$_fileUrl/images').create(recursive: true);
    _newPath = '${_newDirectory.path}/image${DateTime.now()}.jpg';
    
    await _pictureController.takePicture(_newPath);
    Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(newfileSource: _newPath)));
  }

  Future<void> _recordVideo() async{
    if (!_isRecording){
      List<Directory>? _fileDirectory = await (Platform.isAndroid ? getExternalStorageDirectories() : getExternalCacheDirectories());
      String _fileUrl = _fileDirectory![0].path;
      Directory _newDirectory = await Directory('$_fileUrl/videos').create(recursive: true);

      _newPath = '${_newDirectory.path}/image${DateTime.now()}.mp4';
      await _videoController.recordVideo(_newPath);
    }else{
      await _videoController.stopRecordingVideo();
      Navigator.push(context, MaterialPageRoute(builder: (context) => ImageViewer(newfileSource: _newPath)));
    }

    _isRecording = !_isRecording;
    
}

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, _, __) {
        return Scaffold(
          body: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  height: 100.h,
                  width: 100.w,
                  child: CameraAwesome(
                    testMode: false,
                    enableAudio: _enableAudio,
                    onPermissionsResult: (bool? result) { },
                    selectDefaultSize: (List<Size> availableSizes) => Size(1920, 1080),
                    onCameraStarted: () { },
                    sensor: _sensor,
                    photoSize: _photoSize,
                    switchFlashMode: _switchFlash,
                    captureMode: _captureMode,
                    fitted: true,
                  ),
                )
              ),

              Positioned(
                left: 0,
                bottom: 10.h,
                child: Container(
                  width: 100.w,
                  child: Center(
                    child: InkWell(
                      onTap: (){_takeShot();},
                      onLongPress: (){_recordVideo();},
                      child: AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _child) {
                          return Container(
                            height: 15.w * _scalerAnimation.value,
                            width: 15.w * _scalerAnimation.value,
                            child: Icon(
                              Icons.video_camera_back_outlined,
                              size: 32,
                              color: Theme.of(context).backgroundColor,
                              ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).accentColor.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(7.5.w * _scalerAnimation.value)
                            ),
                          );
                        }
                      ),
                    )
                  ),
                )
              ),

              Positioned(
                right: 10.w,
                bottom: 10.h,
                child: InkWell(
                  onTap: (){_toggleLight();},
                  child: Container(
                    height: 50,
                    child: Icon(
                      Icons.lightbulb,
                      size: 28,
                      color: Theme.of(context).backgroundColor,
                      ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(7.5.w * _scalerAnimation.value)
                    ),
                  ),
                )
              ),

              Positioned(
                left: 10.w,
                bottom: 10.h,
                child: InkWell(
                  onTap: (){_toggleCamera();},
                  child: Container(
                    height: 50,
                    child: Icon(
                      (_sensor == ValueNotifier(Sensors.FRONT)) ? Icons.camera_front : Icons.photo_camera_back,
                      size: 28,
                      color: Theme.of(context).backgroundColor,
                      ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).accentColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(7.5.w * _scalerAnimation.value)
                    ),
                  ),
                )
              )
            ],
          ),
        );
      }
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}


class ImageViewer extends StatefulWidget {
  final String newfileSource;
  const ImageViewer({ Key? key, required this.newfileSource}) : super(key: key);

  @override
  _ImageViewerState createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {

  _deleteImage() async{
    Navigator.pop(context);
    File(widget.newfileSource).delete();
  }

  _postImage() async{
    
    
    dynamic _data = await FileRequestData(
      url: '/user/content/post',
      arg: {},
      files: {
        'image': widget.newfileSource
      }
    ).request();

    print("Message: $_data");
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              height: 100.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor
              ),
              child: Image.file(
                File(widget.newfileSource),
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            child: Container(
              height: 10.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).backgroundColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(5.w))
              ),
            ),
          ),

          Positioned(
            bottom: 2.h,
            left: 5.w,
            child: InkWell(
              onTap: (){_deleteImage();},
              child: Icon(
                Icons.delete_forever_outlined,
                size: 32.sp,
              ),
            )
          ),

          Positioned(
            bottom: 2.h,
            right: 5.w,
            child: InkWell(
              onTap: (){_postImage();},
              child: Container(
                height: 40,
                width: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                ),
                child: Center(
                  child: Text(
                    "Post",
                    style: TextStyle(
                      fontSize: 22,
                    ),
                  ),
                )
              ),
            )
          )
        ],
      )
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _deleteImage();
  }
}

