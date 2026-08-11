import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nefqa/features/expenses/view_models/add_edit_expenses_view_model.dart';
import 'package:provider/provider.dart';
import '../../../core/enum/expense_category.dart';
import '../../../core/network/result.dart';

class AddEditExpenseScreenBody extends StatefulWidget {
  const AddEditExpenseScreenBody({super.key});

  @override
  State<AddEditExpenseScreenBody> createState() =>
      _AddEditExpenseScreenBodyState();
}

class _AddEditExpenseScreenBodyState extends State<AddEditExpenseScreenBody> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _selectedCategory = ExpenseCategory.food;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<AddEditExpensesViewModel>();
    final existing = viewModel.existingExpense;

    if (existing != null) {
      _amountController.text = existing.amount.toString();
      _noteController.text = existing.note ?? '';
      _selectedCategory = existing.category;
      _selectedDate = existing.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditExpensesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<ExpenseCategory>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: ExpenseCategory.values.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category.toLabel()),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Date: ${_selectedDate.toLocal()}'.split(' ')[0]),
                TextButton(
                  onPressed: _pickDate,
                  child: const Text('Change Date'),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 24),

            ListenableBuilder(
              listenable: viewModel.saveCommand,
              builder: (context, _) {
                if (viewModel.saveCommand.running) {
                  return const Center(child: CircularProgressIndicator());
                }

                return ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount == null) return;

                    viewModel.saveCommand.execute((
                      amount: amount,
                      category: _selectedCategory,
                      date: _selectedDate,
                      note: _noteController.text.isEmpty
                          ? null
                          : _noteController.text,
                    ));
                  },
                  child: Text(viewModel.isEditing ? 'Save Changes' : 'Add'),
                );
              },
            ),

            ListenableBuilder(
              listenable: viewModel.saveCommand,
              builder: (context, _) {
                if (viewModel.saveCommand.completed) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) context.pop();
                  });
                }

                if (viewModel.saveCommand.error) {
                  final result = viewModel.saveCommand.result as Failure;
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      result.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}
