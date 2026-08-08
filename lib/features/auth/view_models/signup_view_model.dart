import 'package:flutter/foundation.dart';
import '../../../core/network/command.dart';
import '../../../core/network/result.dart';
import '../../../data/models/app_user.dart';
import '../../../data/repositories/auth_repository.dart';

class SignupViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  SignupViewModel(this._authRepository) {
    signUpCommand =
        ParameterizedCommand<
          AppUser,
          ({String email, String password, String name})
        >(_signUp);
  }

  late final ParameterizedCommand<
    AppUser,
    ({String email, String password, String name})
  >
  signUpCommand;

  Future<Result<AppUser>> _signUp(
    ({String email, String password, String name}) args,
  ) {
    return _authRepository.signUp(
      email: args.email,
      password: args.password,
      name: args.name,
    );
  }
}
