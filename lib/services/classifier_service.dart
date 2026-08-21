import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/authentication_result.dart';

class ClassifierService {
  // ============================================================
  // CONFIGURATION
  // ============================================================

  static const String modelPath =
      'assets/models/mobilevit_model.tflite';

  static const double confidenceThreshold = 0.31;

  static const int imageSize = 256;

  Interpreter? _interpreter;

  // ============================================================
  // INITIALIZE MODEL
  // ============================================================

  Future<void> initialize() async {
    if (_interpreter != null) {
      return;
    }

    _interpreter = await Interpreter.fromAsset(
      modelPath,
    );

    print('==========================================');
    print('MobileViT TFLite model loaded');
    print('Input tensors:');
    print(_interpreter!.getInputTensors());
    print('Output tensors:');
    print(_interpreter!.getOutputTensors());
    print('==========================================');
  }

  // ============================================================
  // CLASSIFY IMAGE
  // ============================================================

  Future<AuthenticationResult> classifyImage(
    String imagePath,
  ) async {
    await initialize();

    final interpreter = _interpreter!;

    // ----------------------------------------------------------
    // 1. READ IMAGE
    // ----------------------------------------------------------

    final imageBytes =
        await File(imagePath).readAsBytes();

    final decodedImage =
        img.decodeImage(imageBytes);

    if (decodedImage == null) {
      throw Exception(
        'Could not decode image: $imagePath',
      );
    }

    // ----------------------------------------------------------
    // 2. RESIZE TO 288 x 288
    // ----------------------------------------------------------

    final resized = img.copyResize(
      decodedImage,
      width: 288,
      height: 288,
      interpolation: img.Interpolation.linear,
    );

    // ----------------------------------------------------------
    // 3. CENTER CROP TO 256 x 256
    // ----------------------------------------------------------

    final left =
        (resized.width - imageSize) ~/ 2;

    final top =
        (resized.height - imageSize) ~/ 2;

    final cropped = img.copyCrop(
      resized,
      x: left,
      y: top,
      width: imageSize,
      height: imageSize,
    );

    // ----------------------------------------------------------
    // 4. CREATE INPUT TENSOR
    //
    // Shape:
    // [1, 256, 256, 3]
    //
    // RGB float32
    //
    // Normalization:
    // (pixel / 255 - 0.5) / 0.5
    // ----------------------------------------------------------

    final input = [
      List.generate(
        imageSize,
        (y) => List.generate(
          imageSize,
          (x) {
            final pixel =
                cropped.getPixel(x, y);

            final r =
                pixel.r.toDouble() / 255.0;

            final g =
                pixel.g.toDouble() / 255.0;

            final b =
                pixel.b.toDouble() / 255.0;

            return [
              (r - 0.5) / 0.5,
              (g - 0.5) / 0.5,
              (b - 0.5) / 0.5,
            ];
          },
        ),
      ),
    ];

    // ----------------------------------------------------------
    // 5. OUTPUT
    //
    // 0 = me
    // 1 = teammate
    // 2 = professor
    // ----------------------------------------------------------

    final output = [
      List<double>.filled(
        3,
        0.0,
      ),
    ];

    // ----------------------------------------------------------
    // 6. RUN TFLITE
    // ----------------------------------------------------------

    interpreter.run(
      input,
      output,
    );

    final rawOutput =
        List<double>.from(output[0]);

    print('\n==========================================');
    print('MODEL OUTPUT');
    print('==========================================');

    print(
      'Raw output: $rawOutput',
    );

    // ----------------------------------------------------------
    // 7. SOFTMAX
    // ----------------------------------------------------------

    final probabilities =
        _softmax(rawOutput);

    print(
      'Probabilities: $probabilities',
    );

    // ----------------------------------------------------------
    // 8. GET INDIVIDUAL CLASS PROBABILITIES
    // ----------------------------------------------------------

    final meProbability =
        probabilities[0];

    final teammateProbability =
        probabilities[1];

    final professorProbability =
        probabilities[2];

    print(
      'Me: '
      '${(meProbability * 100).toStringAsFixed(2)}%',
    );

    print(
      'Teammate: '
      '${(teammateProbability * 100).toStringAsFixed(2)}%',
    );

    print(
      'Professor: '
      '${(professorProbability * 100).toStringAsFixed(2)}%',
    );

    // ----------------------------------------------------------
    // 9. FIND HIGHEST-PROBABILITY MODEL CLASS
    // ----------------------------------------------------------

    int predictedId = 0;

    for (
      int i = 1;
      i < probabilities.length;
      i++
    ) {
      if (
        probabilities[i] >
        probabilities[predictedId]
      ) {
        predictedId = i;
      }
    }

    final predictedClass =
        _className(predictedId);

    final maxConfidence =
        probabilities[predictedId];

    print(
      'Highest model prediction: '
      '$predictedClass '
      '(${(maxConfidence * 100).toStringAsFixed(2)}%)',
    );

    // ----------------------------------------------------------
    // 10. APPLICATION DECISION
    //
    // SPECIAL RULE:
    //
    // If PROFESSOR >= 31%
    //     -> Class B
    //
    // Otherwise:
    //     me OR teammate -> Class A
    //     if highest confidence < 31% -> Unknown
    //
    // Professor gets priority over me/teammate.
    // ----------------------------------------------------------

    AuthClass authClass;
    double applicationConfidence;

    if (professorProbability >= confidenceThreshold) {

      // --------------------------------------------------------
      // PROFESSOR HAS PRIORITY
      // --------------------------------------------------------

      authClass =
          AuthClass.classB;

      applicationConfidence =
          professorProbability;

      print(
        'Professor probability >= '
        '${confidenceThreshold * 100}%'
      );

      print(
        'APPLICATION RESULT: CLASS B',
      );

    } else if (
        meProbability >= confidenceThreshold ||
        teammateProbability >= confidenceThreshold
    ) {

      // --------------------------------------------------------
      // CLASS A
      //
      // Use whichever Class A person has higher probability.
      // --------------------------------------------------------

      authClass =
          AuthClass.classA;

      applicationConfidence =
          max(
            meProbability,
            teammateProbability,
          );

      print(
        'APPLICATION RESULT: CLASS A',
      );

    } else {

      // --------------------------------------------------------
      // NOTHING REACHED 31%
      // --------------------------------------------------------

      authClass =
          AuthClass.unknown;

      applicationConfidence =
          maxConfidence;

      print(
        'No class reached '
        '${confidenceThreshold * 100}%'
      );

      print(
        'APPLICATION RESULT: UNKNOWN',
      );
    }

    print(
      'Application confidence: '
      '${(applicationConfidence * 100).toStringAsFixed(2)}%',
    );

    print('==========================================\n');

    // ----------------------------------------------------------
    // 11. RETURN RESULT
    // ----------------------------------------------------------

    return AuthenticationResult(
      authClass: authClass,
      confidence: applicationConfidence,
    );
  }

  // ============================================================
  // SOFTMAX
  // ============================================================

  List<double> _softmax(
    List<double> logits,
  ) {
    final maxLogit =
        logits.reduce(max);

    final exponentials =
        logits.map(
      (value) =>
          exp(value - maxLogit),
    ).toList();

    final sum =
        exponentials.reduce(
      (a, b) => a + b,
    );

    return exponentials.map(
      (value) =>
          value / sum,
    ).toList();
  }

  // ============================================================
  // CLASS NAME
  // ============================================================

  String _className(
    int id,
  ) {
    switch (id) {
      case 0:
        return 'me';

      case 1:
        return 'teammate';

      case 2:
        return 'professor';

      default:
        return 'unknown';
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }
}