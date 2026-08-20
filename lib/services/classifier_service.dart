import '../models/authentication_result.dart';

class ClassifierService {
  Future<AuthenticationResult> classifyImage(String imagePath) async {
    // ------------------------------------------------------------
    // TEMPORARY PLACEHOLDER
    //
    // Later:
    // imagePath -> preprocessing -> ML model -> result
    // ------------------------------------------------------------

    await Future.delayed(
      const Duration(seconds: 2),
    );

    // Change this to classB to test the Class B flow.
    return const AuthenticationResult(
      authClass: AuthClass.classB,
      confidence: 0.94,
    );
  }
}