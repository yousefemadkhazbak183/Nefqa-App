import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/core/network/expenses_data_notifier.dart';
import 'package:nefqa/data/models/expense.dart';
import 'package:nefqa/data/models/expense_statics.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/data/repositories/expense_repository.dart';
import 'package:nefqa/features/statistics/view_models/statistics_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockExpenseRepository mockExpenseRepository;
  late MockAuthRepository mockAuthRepository;
  late ExpensesDataNotifier dataNotifier;
  late StatisticsViewModel viewModel;

  final expenses = [
    Expense(
      id: 1,
      userId: 'user-1',
      amount: 100,
      category: ExpenseCategory.food,
      date: DateTime(2026, 1, 1),
    ),
    Expense(
      id: 2,
      userId: 'user-1',
      amount: 50,
      category: ExpenseCategory.food,
      date: DateTime(2026, 1, 2),
    ),
    Expense(
      id: 3,
      userId: 'user-1',
      amount: 200,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 1, 3),
    ),
  ];

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    mockAuthRepository = MockAuthRepository();
    dataNotifier = ExpensesDataNotifier();

    when(() => mockAuthRepository.getCurrentUserId()).thenReturn('user-1');

    viewModel = StatisticsViewModel(
      mockExpenseRepository,
      mockAuthRepository,
      dataNotifier,
    );
  });

  group('StatisticsViewModel', () {
    test('calculates total and per-category totals correctly', () async {
      when(
        () => mockExpenseRepository.getExpenses('user-1'),
      ).thenAnswer((_) async => Success(expenses));

      await viewModel.loadStatisticsCommand.execute();

      final result =
          viewModel.loadStatisticsCommand.result as Success<ExpenseStatics>;
      final stats = result.data;

      expect(stats.total, 350);
      expect(stats.categoryTotal[ExpenseCategory.food], 150);
      expect(stats.categoryTotal[ExpenseCategory.transport], 200);
      expect(stats.categoryTotal[ExpenseCategory.bills], null);
    });

    test('fails when repository returns Failure', () async {
      when(
        () => mockExpenseRepository.getExpenses('user-1'),
      ).thenAnswer((_) async => Failure('Network error'));

      await viewModel.loadStatisticsCommand.execute();

      expect(viewModel.loadStatisticsCommand.error, true);
    });

    test('automatically reloads when ExpensesDataNotifier fires', () async {
      when(
        () => mockExpenseRepository.getExpenses('user-1'),
      ).thenAnswer((_) async => Success(expenses));

      dataNotifier.notifyExpensesChanged();

      await Future.delayed(Duration.zero);

      verify(() => mockExpenseRepository.getExpenses('user-1')).called(1);
    });
  });
}
