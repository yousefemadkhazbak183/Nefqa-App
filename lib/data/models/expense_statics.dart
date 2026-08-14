import 'package:nefqa/core/enum/expense_category.dart';

class ExpenseStatics {
  final double total;
  final Map<ExpenseCategory, double> categoryTotal;

  ExpenseStatics({required this.total, required this.categoryTotal});
}
