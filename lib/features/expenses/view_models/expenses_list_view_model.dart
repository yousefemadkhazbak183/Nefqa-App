import 'package:flutter/foundation.dart';
import 'package:nefqa/core/network/command.dart';
import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/models/expense.dart';
import 'package:nefqa/data/repositories/auth_repository.dart';
import 'package:nefqa/data/repositories/expense_repository.dart';

class ExpensesListViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AuthRepository _authRepository;

  ExpensesListViewModel(this._expenseRepository, this._authRepository) {
    loadExpensesCommand = SimpleCommand<List<Expense>>(_loadExpensesCommand);
    deleteExpensesCommand = ParameterizedCommand<void, int>(_deleteExpenses);
  }
  late final SimpleCommand<List<Expense>> loadExpensesCommand;
  late final ParameterizedCommand<void, int> deleteExpensesCommand;

  Future<Result<List<Expense>>> _loadExpensesCommand() async {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      return Failure("User logged in");
    }
    return _expenseRepository.getExpense(userId);
  }

  Future<Result<void>> _deleteExpenses(int id) async {
    final result = await _expenseRepository.deleteExpense(id);
    if (result is Success<void>) {
      await loadExpensesCommand.execute();
    }
    return result;
  }
}
