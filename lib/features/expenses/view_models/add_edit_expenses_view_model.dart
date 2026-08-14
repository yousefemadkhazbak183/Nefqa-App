import 'package:flutter/foundation.dart';
import 'package:nefqa/core/network/command.dart';
import 'package:nefqa/core/network/result.dart';

import '../../../core/enum/expense_category.dart';
import '../../../core/network/expenses_data_notifier.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/expense_repository.dart';

class AddEditExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AuthRepository _authRepository;
  final ExpensesDataNotifier _dataNotifier;
  final Expense? existingExpense;

  AddEditExpenseViewModel(
    this._expenseRepository,
    this._authRepository,
    this._dataNotifier, {
    this.existingExpense,
  }) {
    saveCommand =
        ParameterizedCommand<
          Expense,
          ({
            double amount,
            ExpenseCategory category,
            DateTime date,
            String? note,
          })
        >(_save);
  }

  late final ParameterizedCommand<
    Expense,
    ({double amount, ExpenseCategory category, DateTime date, String? note})
  >
  saveCommand;

  bool get isEditing => existingExpense != null;

  Future<Result<Expense>> _save(
    ({double amount, ExpenseCategory category, DateTime date, String? note})
    args,
  ) async {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      return Failure('User not logged in.');
    }

    final expense = Expense(
      id: existingExpense?.id,
      userId: userId,
      amount: args.amount,
      category: args.category,
      date: args.date,
      note: args.note,
    );

    final result = isEditing
        ? await _expenseRepository.updateExpense(expense)
        : await _expenseRepository.addExpense(expense);

    if (result is Success<Expense>) {
      _dataNotifier.notifyExpensesChanged();
    }

    return result;
  }
}
