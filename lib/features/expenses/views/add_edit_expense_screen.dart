import 'package:flutter/material.dart';
import 'package:nefqa/features/expenses/view_models/add_edit_expenses_view_model.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../../../data/models/expense.dart';
import '../widgets/add_edit_expense_screen_body.dart';

class AddEditExpenseScreen extends StatelessWidget {
  final Expense? existingExpense;

  const AddEditExpenseScreen({super.key, this.existingExpense});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<AddEditExpensesViewModel>(param1: existingExpense),
      child: const AddEditExpenseScreenBody(),
    );
  }
}
