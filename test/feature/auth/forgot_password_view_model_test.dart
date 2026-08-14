import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/features/auth/view_models/forget_password_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late ForgotPasswordViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = ForgotPasswordViewModel(mockAuthRepository);
  });

  group('ForgotPasswordViewModel', () {
    test('reset password succeeds', () async {
      when(
        () => mockAuthRepository.resetPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => Success(null));

      await viewModel.resetPasswordCommand.execute('test@test.com');

      expect(viewModel.resetPasswordCommand.completed, true);

      verify(
        () => mockAuthRepository.resetPassword(email: 'test@test.com'),
      ).called(1);
    });

    test('reset password fails when email not found', () async {
      when(
        () => mockAuthRepository.resetPassword(email: any(named: 'email')),
      ).thenAnswer((_) async => Failure('Email not found'));

      await viewModel.resetPasswordCommand.execute('unknown@test.com');

      expect(viewModel.resetPasswordCommand.error, true);
    });
  });
}
