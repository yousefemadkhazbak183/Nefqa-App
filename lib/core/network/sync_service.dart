import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/expense_local_data_source.dart';
import '../../data/repositories/expense_remote_data_source.dart';
import 'expenses_data_notifier.dart';

class SyncService {
  final ExpenseLocalDataSource _localDataSource;
  final ExpenseRemoteDataSource _remoteDataSource;
  final ExpensesDataNotifier _dataNotifier;

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isSyncing = false;

  SyncService(
    this._localDataSource,
    this._remoteDataSource,
    this._dataNotifier,
  );

  void start() {
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        syncPendingExpenses();
      }
    });
  }

  void dispose() {
    _subscription?.cancel();
  }

  Future<void> syncPendingExpenses() async {
    if (_isSyncing) return;
    _isSyncing = true;

    try {
      final pending = await _localDataSource.getUnsyncedExpenses();
      if (pending.isEmpty) return;

      for (final expense in pending) {
        try {
          final synced = await _remoteDataSource.addExpense(expense);
          await _localDataSource.replaceLocalId(
            expense.id!,
            synced.copyWith(isSynced: true),
          );
        } catch (_) {
          // لسه مفيش نت فعلي، أو فشل مؤقت — هنحاول تاني المرة الجاية
        }
      }

      _dataNotifier.notifyExpensesChanged();
    } finally {
      _isSyncing = false;
    }
  }
}
