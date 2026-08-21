import 'package:flutter/foundation.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/data/models/expense_statics.dart';
import '../../../core/network/command.dart';
import '../../../core/network/result.dart';
import '../../../core/network/expenses_data_notifier.dart';
import '../../../data/models/expense.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/expense_repository.dart';

class StatisticsViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AuthRepository _authRepository;
  final ExpensesDataNotifier _dataNotifier;

  StatisticsViewModel(
    this._expenseRepository,
    this._authRepository,
    this._dataNotifier,
  ) {
    loadStatisticsCommand = SimpleCommand<ExpenseStatics>(_loadStatistics);
    _dataNotifier.addListener(_onExpensesChanged);
  }

  late final SimpleCommand<ExpenseStatics> loadStatisticsCommand;

  void _onExpensesChanged() {
    loadStatisticsCommand.execute();
  }

  @override
  void dispose() {
    _dataNotifier.removeListener(_onExpensesChanged);
    super.dispose();
  }

  Future<Result<ExpenseStatics>> _loadStatistics() async {
    final userId = _authRepository.getCurrentUserId();
    if (userId == null) {
      return Failure('User not logged in.');
    }

    final result = await _expenseRepository.getExpenses(userId);

    if (result is Failure<List<Expense>>) {
      return Failure(result.message);
    }

    final expenses = (result as Success<List<Expense>>).data;
    final statistics = _calculateStatistics(expenses);

    return Success(statistics);
  }

  ExpenseStatics _calculateStatistics(List<Expense> expenses) {
    final categoryTotals = <ExpenseCategory, double>{};
    double total = 0;

    for (final expense in expenses) {
      total += expense.amount;
      categoryTotals[expense.category] =
          (categoryTotals[expense.category] ?? 0) + expense.amount;
    }

    return ExpenseStatics(total: total, categoryTotal: categoryTotals);
  }
}
