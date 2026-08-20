import 'package:flutter/material.dart';

class AnalyzingScreen extends StatelessWidget {
  const AnalyzingScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF36D9FF),
                  width: 3,
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF36D9FF),
                ),
              ),
            ),

            const SizedBox(height: 35),

            const Text(
              'ANALYZING',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Verifying identity...',
              style: TextStyle(
                color: Color(0xFF8FA3B8),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please wait',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}