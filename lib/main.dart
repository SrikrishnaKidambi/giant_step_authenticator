import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'screens/camera_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();

  runApp(
    GiantStepApp(cameras: cameras),
  );
}

class GiantStepApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const GiantStepApp({
    super.key,
    required this.cameras,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Giant Step',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111F),
        useMaterial3: true,
      ),
      home: CameraScreen(cameras: cameras),
    );
  }
}