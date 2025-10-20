import '../../../../Models/AuthenticationModels/login_model.dart';
import 'auth_result.dart';

abstract class AuthenticationStrategy {
  Future<AuthenticationResult> authenticate({
    required LoginResponse response,
    required String username,
    required String password,
  });

  String get strategyName;
}
