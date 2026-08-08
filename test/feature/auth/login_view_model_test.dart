import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/models/app_user.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/features/auth/view_models/login_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late LoginViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = LoginViewModel(mockAuthRepository);
  });

  group('LoginViewModel', () {
    test('initial state has no result and is not running', () {
      expect(viewModel.loginCommand.running, false);
      expect(viewModel.loginCommand.result, null);
    });

    test('login succeeds and sets result to Success', () async {
      final fakeUser = AppUser(id: '1', email: 'test@test.com', name: 'Test');

      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Success(fakeUser));

      await viewModel.loginCommand.execute((
        email: 'test@test.com',
        password: '123456',
      ));

      expect(viewModel.loginCommand.completed, true);
      expect(viewModel.loginCommand.running, false);
    });

    test('login fails and sets result to Failure', () async {
      when(
        () => mockAuthRepository.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => Failure('Invalid credentials'));

      await viewModel.loginCommand.execute((
        email: 'wrong@test.com',
        password: 'wrongpass',
      ));

      expect(viewModel.loginCommand.error, true);
      expect(viewModel.loginCommand.running, false);
    });
  });
}
