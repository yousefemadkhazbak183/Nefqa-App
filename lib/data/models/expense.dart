import '../../core/enum/expense_category.dart';

class Expense {
  final int? id;
  final String userId;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;

  const Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategoryX.fromLabel(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'amount': amount,
      'category': category.toLabel(),
      'date': date.toIso8601String().split('T')[0],
      'note': note,
    };
  }
}
