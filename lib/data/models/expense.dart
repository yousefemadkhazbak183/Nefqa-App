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
      userId: json['userId'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategoryX.fromLabel(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'amount': amount,
      'category': category.toLabel(),
      'date': date.toIso8601String(),
      'note': note,
    };
  }
}
