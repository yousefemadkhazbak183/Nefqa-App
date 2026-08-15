import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/widgets/category_style.dart';
import '../../../data/models/expense.dart';
import '../view_models/expenses_list_view_model.dart';

class ExpensesListScreenBody extends StatefulWidget {
  const ExpensesListScreenBody({super.key});

  @override
  State<ExpensesListScreenBody> createState() => _ExpensesListScreenBodyState();
}

class _ExpensesListScreenBodyState extends State<ExpensesListScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpensesListViewModel>().loadExpensesCommand.execute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ExpensesListViewModel>();
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nafqa'),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel.loadExpensesCommand,
        builder: (context, _) {
          final command = viewModel.loadExpensesCommand;

          if (command.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (command.error) {
            final result = command.result as Failure;
            return Center(
              child: Text(
                result.message,
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            );
          }

          if (command.completed) {
            final result = command.result as Success<List<Expense>>;
            final expenses = result.data;
            final total = expenses.fold<double>(0, (sum, e) => sum + e.amount);

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.surface(context),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total this month',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${total.toStringAsFixed(0)} EGP',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Recent expenses',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: expenses.isEmpty
                        ? Center(
                            child: Text(
                              'No expenses yet.',
                              style: TextStyle(
                                color: AppColors.textMuted(context),
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: expenses.length,
                            separatorBuilder: (_, _) => Divider(
                              height: 1,
                              color: AppColors.surfaceElevated(context),
                            ),
                            itemBuilder: (context, index) {
                              final expense = expenses[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await context.push(
                                      '/expenses/edit',
                                      extra: expense,
                                    );
                                    if (context.mounted) {
                                      context
                                          .read<ExpensesListViewModel>()
                                          .loadExpensesCommand
                                          .execute();
                                    }
                                  },
                                  onLongPress: () {
                                    viewModel.deleteExpenseCommand.execute(
                                      expense.id!,
                                    );
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceElevated(
                                            context,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          categoryIcon(expense.category),
                                          size: 18,
                                          color: categoryColor(
                                            expense.category,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              expense.category.toLabel(),
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              '${expense.date.day}/${expense.date.month}/${expense.date.year}',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: AppColors.textMuted(
                                                  context,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        '${expense.amount.toStringAsFixed(0)} EGP',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.textPrimary(context),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent(context),
        foregroundColor: AppColors.background(context),
        onPressed: () async {
          await context.push('/expenses/add');
          if (context.mounted) {
            context.read<ExpensesListViewModel>().loadExpensesCommand.execute();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
