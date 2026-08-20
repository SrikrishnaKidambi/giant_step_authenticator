enum AuthClass {
  classA,
  classB,
  unknown,
}

class AuthenticationResult {
  final AuthClass authClass;
  final double confidence;

  const AuthenticationResult({
    required this.authClass,
    required this.confidence,
  });
}