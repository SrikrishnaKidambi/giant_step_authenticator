import 'package:flutter/services.dart';

class PythonService {
  static const MethodChannel _channel = MethodChannel('com.example.giant_step_authenticator/python');

  static Future<String> runPythonScript(String scriptContent, List<String> args) async {
    try {
      final result = await _channel.invokeMethod('runPython', {
        'script': scriptContent,
        'args': args,
      });
      return result.toString();
    } on PlatformException catch (e) {
      throw Exception('Python execution failed: ${e.message}');
    }
  }
}