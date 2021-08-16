import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:kinco/models/post.dart';
import 'package:sizer/sizer.dart';

class ContentTile extends StatefulWidget {
  final PostModel? data;
  const ContentTile({Key? key, this.data}) : super(key: key);

  @override
  _ContentTileState createState() => _ContentTileState();
}

class _ContentTileState extends State<ContentTile> {
  late PostModel data;
  @override
  Widget build(BuildContext context) {
    
    return Container(
      height: 110.w,
      width: 96.w,
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            blurRadius: 2,
            offset: Offset.infinite,
            color: Theme.of(context).primaryColorLight
          ),
          BoxShadow(
            blurRadius: 2,
            offset: Offset.infinite,
            color: Theme.of(context).primaryColor
          ), 
          BoxShadow(
            blurRadius: 2,
            offset: Offset.infinite,
            color: Theme.of(context).primaryColorDark
          )
        ]
      ),
      child: Column(
        children: [
          Container(
            height: 110.w,
            width: 94.w,
            child: widget.data == null ? SizedBox() :Image.network(
              widget.data!.videoUrl,
              fit: BoxFit.fitWidth,
              ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Theme.of(context).cardColor,
            )
          )
        ],
      ),
    );
  }
}
