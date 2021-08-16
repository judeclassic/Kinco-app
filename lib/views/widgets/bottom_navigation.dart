import 'package:flutter/material.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({Key? key}) : super(key: key);

  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          InkWell(
            onTap: (){},
            child: Expanded(
              child: Center(child: Icon(Icons.home)),
            ),
          )
        ],
      ),
    );
  }
}
