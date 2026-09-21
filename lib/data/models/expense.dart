import 'package:nefqa/core/enum/expense_category.dart';

class Expense {
  final int? id;
  final String userId;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final bool isSynced;

  const Expense({
    this.id,
    required this.userId,
    required this.amount,
    required this.category,
    required this.date,
    this.note,
    this.isSynced = true,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategoryX.fromLabel(json['category'] as String),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      isSynced: json['is_synced'] == null ? true : json['is_synced'] == 1,
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

  Map<String, dynamic> toLocalJson() {
    return {...toJson(), 'is_synced': isSynced ? 1 : 0};
  }

  Expense copyWith({int? id, bool? isSynced}) {
    return Expense(
      id: id ?? this.id,
      userId: userId,
      amount: amount,
      category: category,
      date: date,
      note: note,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
