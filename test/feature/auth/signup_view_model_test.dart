import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/models/app_user.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/features/auth/view_models/signup_view_model.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late SignupViewModel viewModel;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    viewModel = SignupViewModel(mockAuthRepository);
  });

  group('SignupViewModel', () {
    test('initial state has no result and is not running', () {
      expect(viewModel.signUpCommand.running, false);
      expect(viewModel.signUpCommand.result, null);
    });

    test('signup succeeds and sets result to Success', () async {
      final fakeUser = AppUser(id: '1', email: 'test@test.com', name: 'Test');

      when(
        () => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Success(fakeUser));

      await viewModel.signUpCommand.execute((
        email: 'test@test.com',
        password: '123456',
        name: 'Test User',
      ));

      expect(viewModel.signUpCommand.completed, true);
      expect(viewModel.signUpCommand.running, false);
    });

    test('signup fails when email already exists', () async {
      when(
        () => mockAuthRepository.signUp(
          email: any(named: 'email'),
          password: any(named: 'password'),
          name: any(named: 'name'),
        ),
      ).thenAnswer((_) async => Failure('Email already in use'));

      await viewModel.signUpCommand.execute((
        email: 'existing@test.com',
        password: '123456',
        name: 'Test User',
      ));

      expect(viewModel.signUpCommand.error, true);
      final result = viewModel.signUpCommand.result as Failure;
      expect(result.message, 'Email already in use');
    });
  });
}
