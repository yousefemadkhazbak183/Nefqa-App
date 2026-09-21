import '../../core/network/result.dart';
import '../models/expense.dart';
import 'expense_local_data_source.dart';
import 'expense_remote_data_source.dart';

abstract class ExpenseRepository {
  Future<Result<List<Expense>>> getExpenses(String userId);
  Future<Result<Expense>> addExpense(Expense expense);
  Future<Result<Expense>> updateExpense(Expense expense);
  Future<Result<void>> deleteExpense(int id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource _remoteDataSource;
  final ExpenseLocalDataSource _localDataSource;

  ExpenseRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<List<Expense>>> getExpenses(String userId) async {
    try {
      final expenses = await _remoteDataSource.getExpenses(userId);
      await _localDataSource.cacheExpenses(expenses);

      // نضيف أي مصاريف لسه متعملهاش sync (اتعملت offline)
      final pending = (await _localDataSource.getUnsyncedExpenses())
          .where((e) => e.userId == userId);

      final combined = [...pending, ...expenses]
        ..sort((a, b) => b.date.compareTo(a.date));

      return Success(combined);
    } catch (_) {
      try {
        final cachedExpenses = await _localDataSource.getExpenses(userId);
        return Success(cachedExpenses);
      } catch (_) {
        return  Failure('Failed to load expenses. Please check your connection.');
      }
    }
  }

  @override
  Future<Result<Expense>> addExpense(Expense expense) async {
    try {
      final addedExpense = await _remoteDataSource.addExpense(expense);
      await _localDataSource.cacheExpenses([addedExpense]);
      return Success(addedExpense);
    } catch (_) {
      // مفيش نت (أو فشل مؤقت) — نخزنه محلياً بـ id مؤقت لحد ما يتزامن
      final tempId = -DateTime.now().millisecondsSinceEpoch;
      final offlineExpense = expense.copyWith(id: tempId, isSynced: false);

      try {
        await _localDataSource.cacheExpenses([offlineExpense]);
        return Success(offlineExpense);
      } catch (_) {
        return  Failure('Failed to add expense. Please try again.');
      }
    }
  }

  @override
  Future<Result<Expense>> updateExpense(Expense expense) async {
    try {
      final updatedExpense = await _remoteDataSource.updateExpense(expense);
      await _localDataSource.cacheExpenses([updatedExpense]);
      return Success(updatedExpense);
    } catch (_) {
      return  Failure('Failed to update expense. Please try again.');
    }
  }

  @override
  Future<Result<void>> deleteExpense(int id) async {
    try {
      await _remoteDataSource.deleteExpense(id);
      await _localDataSource.deleteExpense(id);
      return Success(null);
    } catch (_) {
      return  Failure('Failed to delete expense. Please try again.');
    }
  }
}