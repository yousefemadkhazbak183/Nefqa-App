import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/core/network/expenses_data_notifier.dart';
import 'package:nefqa/data/models/expense.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/data/repositories/expense_repository.dart';
import 'package:nefqa/features/expenses/view_models/add_edit_expenses_view_model.dart';

class MockExpenseRepository extends Mock implements ExpenseRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      Expense(
        id: 0,
        userId: 'fallback',
        amount: 0,
        category: ExpenseCategory.other,
        date: DateTime(2026, 1, 1),
      ),
    );
  });

  late MockExpenseRepository mockExpenseRepository;
  late MockAuthRepository mockAuthRepository;
  late ExpensesDataNotifier dataNotifier;

  setUp(() {
    mockExpenseRepository = MockExpenseRepository();
    mockAuthRepository = MockAuthRepository();
    dataNotifier = ExpensesDataNotifier();

    when(() => mockAuthRepository.getCurrentUserId()).thenReturn('user-1');
  });

  group('AddEditExpenseViewModel - Add mode', () {
    late AddEditExpenseViewModel viewModel;

    setUp(() {
      viewModel = AddEditExpenseViewModel(
        mockExpenseRepository,
        mockAuthRepository,
        dataNotifier,
      );
    });

    test('isEditing is false when no existing expense', () {
      expect(viewModel.isEditing, false);
    });

    test('calls addExpense (not updateExpense) and succeeds', () async {
      final newExpense = Expense(
        id: 1,
        userId: 'user-1',
        amount: 50,
        category: ExpenseCategory.food,
        date: DateTime(2026, 1, 1),
      );

      when(
        () => mockExpenseRepository.addExpense(any()),
      ).thenAnswer((_) async => Success(newExpense));

      await viewModel.saveCommand.execute((
        amount: 50,
        category: ExpenseCategory.food,
        date: DateTime(2026, 1, 1),
        note: null,
      ));

      expect(viewModel.saveCommand.completed, true);
      verify(() => mockExpenseRepository.addExpense(any())).called(1);
      verifyNever(() => mockExpenseRepository.updateExpense(any()));
    });
  });

  group('AddEditExpenseViewModel - Edit mode', () {
    late AddEditExpenseViewModel viewModel;
    final existingExpense = Expense(
      id: 5,
      userId: 'user-1',
      amount: 100,
      category: ExpenseCategory.transport,
      date: DateTime(2026, 1, 1),
    );

    setUp(() {
      viewModel = AddEditExpenseViewModel(
        mockExpenseRepository,
        mockAuthRepository,
        dataNotifier,
        existingExpense: existingExpense,
      );
    });

    test('isEditing is true when existing expense is provided', () {
      expect(viewModel.isEditing, true);
    });

    test(
      'calls updateExpense (not addExpense) and keeps original id',
      () async {
        when(() => mockExpenseRepository.updateExpense(any())).thenAnswer((
          invocation,
        ) async {
          final passedExpense = invocation.positionalArguments[0] as Expense;
          expect(passedExpense.id, 5);
          return Success(passedExpense);
        });

        await viewModel.saveCommand.execute((
          amount: 200,
          category: ExpenseCategory.bills,
          date: DateTime(2026, 2, 1),
          note: 'Updated note',
        ));

        expect(viewModel.saveCommand.completed, true);
        verify(() => mockExpenseRepository.updateExpense(any())).called(1);
        verifyNever(() => mockExpenseRepository.addExpense(any()));
      },
    );
  });
}
