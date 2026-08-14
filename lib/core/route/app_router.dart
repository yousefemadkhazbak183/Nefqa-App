import 'package:go_router/go_router.dart';
import '../../data/models/expense.dart';
import '../../core/widgets/main_navigation_scaffold.dart';
import '../../features/auth/views/login_screen.dart';
import '../../features/auth/views/signup_screen.dart';
import '../../features/auth/views/forgot_password_screen.dart';
import '../../features/expenses/views/expenses_list_screen.dart';
import '../../features/expenses/views/add_edit_expense_screen.dart';
import '../../features/statistics/views/statistics_screen.dart';
import '../../splash_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainNavigationScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/expenses',
              builder: (context, state) => const ExpensesListScreen(),
              routes: [
                GoRoute(
                  path: 'add',
                  builder: (context, state) => const AddEditExpenseScreen(),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (context, state) {
                    final expense = state.extra as Expense;
                    return AddEditExpenseScreen(existingExpense: expense);
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/statistics',
              builder: (context, state) => const StatisticsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
