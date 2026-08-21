import 'package:flutter/foundation.dart';
import '../../../core/network/command.dart';
import '../../../core/network/result.dart';
import '../../../core/network/expenses_data_notifier.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/expense_repository.dart';

class ExpensesListViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AuthRepository _authRepository;
  final ExpensesDataNotifier _dataNotifier;

  ExpensesListViewModel(
    this._expenseRepository,
    this._authRepository,
    this._dataNotifier,
  ) {
    loadExpensesCommand = SimpleCommand<List<Expense>>(_loadExpenses);
    deleteExpenseCommand = ParameterizedCommand<void, int>(_deleteExpense);
  }

  late final SimpleCommand<List<Expense>> loadExpensesCommand;
  late final ParameterizedCommand<void, int> deleteExpenseCommand;

  Future<Result<List<Expense>>> _loadExpenses() async {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      return Failure('User not logged in.');
    }
    return _expenseRepository.getExpenses(userId);
  }

  Future<Result<void>> _deleteExpense(int id) async {
    final result = await _expenseRepository.deleteExpense(id);

    if (result is Success<void>) {
      await loadExpensesCommand.execute();
      _dataNotifier.notifyExpensesChanged();
    }

    return result;
  }
}
