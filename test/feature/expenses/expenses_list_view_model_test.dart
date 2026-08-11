import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/models/expense.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/data/repositories/expense_repository.dart';
import 'package:nefqa/features/expenses/view_models/expenses_list_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockExpenseRepository mockExpenseRepository;
  late MockAuthRepository mockAuthRepository;
  late ExpensesListViewModel viewModel;

  final fakeExpense = Expense(
    id: 1,
    userId: 'user-1',
    amount: 100,
    category: ExpenseCategory.food,
    date: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    mockAuthRepository = MockAuthRepository();

    when(() => mockAuthRepository.getCurrentUserId()).thenReturn('user-1');

    viewModel = ExpensesListViewModel(
      mockExpenseRepository,
      mockAuthRepository,
    );
  });

  group('ExpensesListViewModel', () {
    test('loads expenses successfully', () async {
      when(
        () => mockExpenseRepository.getExpense('user-1'),
      ).thenAnswer((_) async => Success([fakeExpense]));

      await viewModel.loadExpensesCommand.execute();

      expect(viewModel.loadExpensesCommand.completed, true);
      final result =
          viewModel.loadExpensesCommand.result as Success<List<Expense>>;
      expect(result.data.length, 1);
    });

    test('fails when repository returns Failure', () async {
      when(
        () => mockExpenseRepository.getExpense('user-1'),
      ).thenAnswer((_) async => Failure('Network error'));

      await viewModel.loadExpensesCommand.execute();

      expect(viewModel.loadExpensesCommand.error, true);
    });

    test('deleting an expense triggers reload', () async {
      when(
        () => mockExpenseRepository.deleteExpense(1),
      ).thenAnswer((_) async => Success(null));
      when(
        () => mockExpenseRepository.getExpense('user-1'),
      ).thenAnswer((_) async => Success([]));

      await viewModel.deleteExpensesCommand.execute(1);

      verify(() => mockExpenseRepository.deleteExpense(1)).called(1);
      verify(() => mockExpenseRepository.getExpense('user-1')).called(1);
    });
  });
}
