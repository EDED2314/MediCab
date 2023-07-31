import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:medicab/screens/login.dart';
import 'package:medicab/utils/http_overrides.dart';
import 'package:medicab/utils/theme_utils.dart';

void main() async {
  HttpOverrides.global = MyHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  List<ThemeData> themelist = await giveMeLightAndDark();
  ThemeData lightTheme = themelist[0];
  ThemeData darkTheme = themelist[1];

  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(MediCab(
    lightTheme: lightTheme,
    darkTheme: darkTheme,
    camera: firstCamera,
  ));
}

class MediCab extends StatefulWidget {
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final CameraDescription camera;

  const MediCab(
      {super.key,
      required this.lightTheme,
      required this.darkTheme,
      required this.camera});

  @override
  State<MediCab> createState() => _MediCabState();
}

class _MediCabState extends State<MediCab> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediCab',
      theme: widget.lightTheme,
      darkTheme: widget.darkTheme,
      themeMode: ThemeMode.system,
      home: Login(camera: widget.camera),
    );
  }
}
