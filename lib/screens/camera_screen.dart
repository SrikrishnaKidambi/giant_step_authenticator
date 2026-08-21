import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../models/authentication_result.dart';
import '../services/classifier_service.dart';
import 'analyzing_screen.dart';
import 'authenticated_screen.dart';
import 'ransomware_screen.dart';
import '../services/demo_file_service.dart';

class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraScreen({
    super.key,
    required this.cameras,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? controller;

  int? countdown;
  bool isProcessing = false;

  final ClassifierService classifierService =
      ClassifierService();

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

    

  Future<void> initializeCamera() async {
    if (widget.cameras.isEmpty) {
      return;
    }

    final camera = widget.cameras.firstWhere(
      (camera) =>
          camera.lensDirection == CameraLensDirection.front,
      orElse: () => widget.cameras.first,
    );

    controller = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> startCapture() async {
    if (controller == null ||
        !controller!.value.isInitialized ||
        isProcessing) {
      return;
    }

    setState(() {
      isProcessing = true;
      countdown = 5;
    });

    for (int i = 5; i >= 1; i--) {
      if (!mounted) return;

      setState(() {
        countdown = i;
      });

      await Future.delayed(
        const Duration(seconds: 1),
      );
    }

    if (!mounted) return;

    setState(() {
      countdown = null;
    });

    try {
      final XFile image =
          await controller!.takePicture();

      await processImage(image.path);
    } catch (e) {
      debugPrint('Capture error: $e');

      if (mounted) {
        setState(() {
          isProcessing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Unable to capture image: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> processImage(String imagePath) async {
    if (!mounted) return;

    // Show analyzing screen.
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AnalyzingScreen(),
      ),
    );

    final AuthenticationResult result =
        await classifierService.classifyImage(
      imagePath,
    );

    if (!mounted) return;

    // Remove analyzing screen.
    Navigator.pop(context);

    setState(() {
      isProcessing = false;
    });

    if (result.authClass == AuthClass.classA) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AuthenticatedScreen(
            result: result,
          ),
        ),
      );
    } else if (result.authClass == AuthClass.classB) {
      try {
    // Ensure the demo file exists
    if (!await DemoFileService.exists()) {
      await DemoFileService.createDemoFile();
    }
    // Encrypt the file
    await DemoFileService.encryptDemoFile();
    // Now show the ransomware screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RansomwareScreen(result: result),
      ),
    );
  } catch (e) {
    // Show error if encryption fails
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Encryption failed: $e')),
    );
  }
    } else {
      // Unknown result.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Identity could not be verified.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cameras.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'No camera available.',
          ),
        ),
      );
    }

    if (controller == null ||
        !controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // HEADER
            const Text(
              'GIANT STEP',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 5),

            const Text(
              'FACE AUTHENTICATION',
              style: TextStyle(
                fontSize: 12,
                letterSpacing: 3,
                color: Color(0xFF8FA3B8),
              ),
            ),

            const SizedBox(height: 20),

            // CAMERA
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius:
                      BorderRadius.circular(28),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: controller!.value.aspectRatio,
                        child: CameraPreview(controller!),
                      ),

                      // Dark overlay around edges
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(28),
                            border: Border.all(
                              color:
                                  const Color(0xFF36D9FF),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      // FACE GUIDE
                      Container(
                        width: 230,
                        height: 290,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color:
                                const Color(0xFF36D9FF),
                            width: 3,
                          ),
                          borderRadius:
                              BorderRadius.circular(140),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF36D9FF)
                                      .withOpacity(0.35),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),

                      // COUNTDOWN
                      if (countdown != null)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.black
                                .withOpacity(0.65),
                            border: Border.all(
                              color:
                                  const Color(0xFF36D9FF),
                              width: 3,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$countdown',
                              style: const TextStyle(
                                fontSize: 70,
                                fontWeight:
                                    FontWeight.bold,
                                color:
                                    Colors.white,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              isProcessing
                  ? 'Preparing authentication...'
                  : 'Position your face inside the frame',
              style: const TextStyle(
                color: Color(0xFFB7C5D4),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            // CAPTURE BUTTON
            // CAPTURE BUTTON
            GestureDetector(
              onTap: isProcessing
                  ? null
                  : startCapture,
              child: Container(
                width: 220,
                height: 58,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1FA2FF),
                      Color(0xFF12D8FA),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF12D8FA)
                          .withOpacity(0.3),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    isProcessing
                        ? 'PROCESSING...'
                        : 'CAPTURE',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}