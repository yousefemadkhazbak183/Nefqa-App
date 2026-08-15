import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/category_style.dart';
import '../view_models/add_edit_expenses_view_model.dart';

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
    final viewModel = context.read<AddEditExpenseViewModel>();
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
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<AddEditExpenseViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text(viewModel.isEditing ? 'Edit expense' : 'Add expense'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 22,
              ),
              decoration: const InputDecoration(
                labelText: 'Amount',
                suffixText: 'EGP',
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'Category',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: ExpenseCategory.values.map((category) {
                final selected = category == _selectedCategory;
                final color = categoryColor(category);
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? color.withValues(alpha: 0.18)
                          : AppColors.surface(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected ? color : Colors.transparent,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(categoryIcon(category), size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(
                          category.toLabel(),
                          style: TextStyle(
                            fontSize: 13,
                            color: selected
                                ? AppColors.textPrimary(context)
                                : AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.textSecondary(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _pickDate, child: const Text('Change')),
                ],
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _noteController,
              style: TextStyle(color: AppColors.textPrimary(context)),
              decoration: const InputDecoration(labelText: 'Note (optional)'),
            ),
            const SizedBox(height: 28),

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
                  child: Text(
                    viewModel.isEditing ? 'Save changes' : 'Add expense',
                  ),
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
                      style: const TextStyle(color: Colors.redAccent),
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
