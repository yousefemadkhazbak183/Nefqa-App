import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/enum/expense_category.dart';
import '../../../core/network/result.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ListenableBuilder(
        listenable: viewModel.loadExpensesCommand,
        builder: (context, _) {
          final command = viewModel.loadExpensesCommand;

          if (command.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (command.error) {
            final result = command.result as Failure;
            return Center(child: Text(result.message));
          }

          if (command.completed) {
            final result = command.result as Success<List<Expense>>;
            final expenses = result.data;

            if (expenses.isEmpty) {
              return const Center(child: Text('No expenses yet.'));
            }

            return ListView.builder(
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                return ListTile(
                  title: Text(expense.category.toLabel()),
                  subtitle: Text(expense.note ?? ''),
                  trailing: Text('${expense.amount}'),
                  onTap: () async {
                    await context.push('/expenses/edit', extra: expense);
                    if (context.mounted) {
                      context
                          .read<ExpensesListViewModel>()
                          .loadExpensesCommand
                          .execute();
                    }
                  },
                  onLongPress: () {
                    viewModel.deleteExpenseCommand.execute(expense.id!);
                  },
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
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
