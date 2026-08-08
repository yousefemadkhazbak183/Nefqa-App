import 'package:flutter/foundation.dart';
import '../../../core/network/command.dart';
import '../../../core/network/result.dart';
import '../../../data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  ForgotPasswordViewModel(this._authRepository) {
    resetPasswordCommand = ParameterizedCommand<void, String>(_resetPassword);
  }

  late final ParameterizedCommand<void, String> resetPasswordCommand;

  Future<Result<void>> _resetPassword(String email) {
    return _authRepository.resetPassword(email: email);
  }
}
