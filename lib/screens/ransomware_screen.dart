import 'package:flutter/material.dart';
import '../models/authentication_result.dart';
import '../services/ransomware_service.dart';

class RansomwareScreen extends StatefulWidget {
  final AuthenticationResult result;
  const RansomwareScreen({super.key, required this.result});

  @override
  State<RansomwareScreen> createState() => _RansomwareScreenState();
}

class _RansomwareScreenState extends State<RansomwareScreen> {
  bool _isDecrypting = false;

  Future<void> _decrypt() async {
    setState(() => _isDecrypting = true);
    try {
      await RansomwareService.restoreFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Files restored successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Restore failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isDecrypting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final confidence = (widget.result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF180708),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  size: 90,
                  color: Color(0xFFFF4545),
                ),
                const SizedBox(height: 20),
                const Text(
                  'SECURITY ALERT',
                  style: TextStyle(
                    color: Color(0xFFFF4545),
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'RANSOMWARE SIMULATION',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 30),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF260D0E),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFFF4545).withOpacity(0.4),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TARGET CLASSIFIED',
                        style: TextStyle(
                          color: Colors.white54,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'CLASS B',
                        style: TextStyle(
                          color: Color(0xFFFF4545),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        'Confidence: $confidence%',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'You are under ransomware attack.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your files have been locked.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'PAY \$5000 TO RELEASE YOUR FILES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFFF4545),
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 35),
                // ---- NEW DECRYPT BUTTON ----
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isDecrypting ? null : _decrypt,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF19C37D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isDecrypting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'RESTORE FILES',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                            ),
                          ),
                  ),
                ),
                // (Optional) keep the old "CONTROLLED DEMO" as a TextButton
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'CONTROLLED DEMO (exit)',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}