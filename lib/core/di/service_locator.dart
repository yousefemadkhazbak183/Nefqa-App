import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../network/expenses_data_notifier.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/expense_local_data_source.dart';
import '../../data/repositories/expense_remote_data_source.dart';
import '../../data/repositories/expense_repository.dart';
import '../../data/models/expense.dart';
import '../../features/auth/view_models/login_view_model.dart';
import '../../features/auth/view_models/signup_view_model.dart';
import '../../features/auth/view_models/forget_password_view_model.dart';
import '../../features/expenses/view_models/expenses_list_view_model.dart';
import '../../features/expenses/view_models/add_edit_expenses_view_model.dart';
import '../../features/statistics/view_models/statistics_view_model.dart';
import '../theme/theme_notifier.dart';

final getIt = GetIt.instance;

void setupServiceLocator() {
  // Supabase Client — Singleton
  getIt.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Auth Repository — Singleton
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<SupabaseClient>()),
  );

  // Auth ViewModels — Factory
  getIt.registerFactory<LoginViewModel>(
    () => LoginViewModel(getIt<AuthRepository>()),
  );

  getIt.registerFactory<SignupViewModel>(
    () => SignupViewModel(getIt<AuthRepository>()),
  );

  getIt.registerFactory<ForgotPasswordViewModel>(
    () => ForgotPasswordViewModel(getIt<AuthRepository>()),
  );

  // --- Expenses ---

  // HTTP Client — Singleton
  getIt.registerLazySingleton<http.Client>(() => http.Client());

  // Data Sources — Singleton
  getIt.registerLazySingleton<ExpenseRemoteDataSource>(
    () => ExpenseRemoteDataSource(getIt<http.Client>()),
  );

  getIt.registerLazySingleton<ExpenseLocalDataSource>(
    () => ExpenseLocalDataSource(),
  );

  // Expense Repository — Singleton
  getIt.registerLazySingleton<ExpenseRepository>(
    () => ExpenseRepositoryImpl(
      getIt<ExpenseLocalDataSource>(),
      getIt<ExpenseRemoteDataSource>(),
    ),
  );

  // Cross-feature data change notifier — Singleton
  getIt.registerLazySingleton<ExpensesDataNotifier>(
    () => ExpensesDataNotifier(),
  );

  // Expenses ViewModels — Factory
  getIt.registerFactory<ExpensesListViewModel>(
    () => ExpensesListViewModel(
      getIt<ExpenseRepository>(),
      getIt<AuthRepository>(),
      getIt<ExpensesDataNotifier>(),
    ),
  );

  getIt.registerFactoryParam<AddEditExpenseViewModel, Expense?, void>(
    (existingExpense, _) => AddEditExpenseViewModel(
      getIt<ExpenseRepository>(),
      getIt<AuthRepository>(),
      getIt<ExpensesDataNotifier>(),
      existingExpense: existingExpense,
    ),
  );

  // --- Statistics ---

  getIt.registerFactory<StatisticsViewModel>(
    () => StatisticsViewModel(
      getIt<ExpenseRepository>(),
      getIt<AuthRepository>(),
      getIt<ExpensesDataNotifier>(),
    ),
  );
  getIt.registerLazySingleton<ThemeNotifier>(() => ThemeNotifier());
}
