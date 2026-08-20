import 'package:flutter/material.dart';

import '../models/authentication_result.dart';

class AuthenticatedScreen extends StatelessWidget {
  final AuthenticationResult result;

  const AuthenticatedScreen({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final confidence =
        (result.confidence * 100).toStringAsFixed(1);

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding:
                const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF19C37D)
                        .withOpacity(0.12),
                    border: Border.all(
                      color: const Color(0xFF19C37D),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 65,
                    color: Color(0xFF19C37D),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'AUTHENTICATED',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  'You are authenticated',
                  style: TextStyle(
                    color: Color(0xFFB7C5D4),
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 30),

                _InfoCard(
                  title: 'CLASS',
                  value: 'A',
                ),

                const SizedBox(height: 12),

                _InfoCard(
                  title: 'CONFIDENCE',
                  value: '$confidence%',
                ),

                const SizedBox(height: 40),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFF19C37D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'CONTINUE',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
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

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF101D2D),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
        ),
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8FA3B8),
              letterSpacing: 2,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}