import 'package:flutter/foundation.dart';
import 'package:nefqa/core/network/command.dart';
import 'package:nefqa/core/network/result.dart';

import '../../../core/enum/expense_category.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/expense_repository.dart';

class AddEditExpensesViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AuthRepository _authRepository;
  final Expense? existingExpense;

  AddEditExpensesViewModel(
    this._expenseRepository,
    this._authRepository, {
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
      return Failure("User not logged in.");
    }
    final expense = Expense(
      userId: userId,
      amount: args.amount,
      category: args.category,
      date: args.date,
      note: args.note,
      id: existingExpense?.id,
    );
    if (isEditing) {
      return _expenseRepository.updateExpense(expense);
    } else {
      return _expenseRepository.addExpense(expense);
    }
  }
}
