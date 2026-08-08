import 'package:flutter/foundation.dart';
import '../../../core/network/command.dart';
import '../../../core/network/result.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  LoginViewModel(this._authRepository) {
    loginCommand =
        ParameterizedCommand<AppUser, ({String email, String password})>(
          _login,
        );
  }

  late final ParameterizedCommand<AppUser, ({String email, String password})>
  loginCommand;

  Future<Result<AppUser>> _login(({String email, String password}) args) {
    return _authRepository.login(email: args.email, password: args.password);
  }
}
