enum ExpenseCategory { food, transport, bills, entertainment, other }

extension ExpenseCategoryX on ExpenseCategory {
  String toLabel() {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  static ExpenseCategory fromLabel(String label) {
    return ExpenseCategory.values.firstWhere(
      (category) => category.toLabel() == label,
      orElse: () => ExpenseCategory.other,
    );
  }
}
