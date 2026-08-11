import 'package:nefqa/core/network/result.dart';
import 'package:nefqa/data/models/expense.dart';
import 'package:nefqa/data/repositories/expense_local_data_source.dart';
import 'package:nefqa/data/repositories/expense_remote_data_source.dart';

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getExpense(String userId);
  Future<Result<Expense>> addExpense(Expense expense);
  Future<Result<Expense>> updateExpense(Expense expense);
  Future<Result<void>> deleteExpense(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource _expenseLocalDataSource;
  final ExpenseRemoteDataSource _expenseRemoteDataSource;
  ExpenseRepositoryImpl(
    this._expenseLocalDataSource,
    this._expenseRemoteDataSource,
  );

  @override
  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _expenseRemoteDataSource.deleteExpense(id);
      await _expenseLocalDataSource.deleteExpense(id);
      return Success(null);
    } catch (_) {
      return Failure("Failed to delete expense. Please try again.");
    }
  }

  @override
  Future<Result<List<Expense>>> getExpense(String userId) async {
    try {
      final expenses = await _expenseRemoteDataSource.getExpenses(userId);
      await _expenseLocalDataSource.cacheExpenses(expenses);
      return Success(expenses);
    } catch (_) {
      try {
        final cachedExpenses = await _expenseLocalDataSource.getExpenses(
          userId,
        );
        return Success(cachedExpenses);
      } catch (_) {
        return Failure(
          "Failed to load expenses. Please check your connection.",
        );
      }
    }
  }

  @override
  Future<Result<Expense>> addExpense(Expense expense) async {
    try {
      final addExpense = await _expenseRemoteDataSource.addExpense(expense);
      await _expenseLocalDataSource.cacheExpenses([addExpense]);
      return Success(addExpense);
    } catch (_) {
      return Failure("Failed to add expense. Please try again.");
    }
  }

  @override
  Future<Result<Expense>> updateExpense(Expense expense) async {
    try {
      final updatedExpense = await _expenseRemoteDataSource.updateExpense(
        expense,
      );
      await _expenseLocalDataSource.cacheExpenses([updatedExpense]);
      return Success(updatedExpense);
    } catch (_) {
      return Failure('Failed to update expense. Please try again.');
    }
  }
}
