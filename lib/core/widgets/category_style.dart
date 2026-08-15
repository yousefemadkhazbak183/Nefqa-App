import 'package:flutter/material.dart';
import '../enum/expense_category.dart';
import '../theme/app_colors.dart';

IconData categoryIcon(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return Icons.restaurant_rounded;
    case ExpenseCategory.transport:
      return Icons.directions_car_rounded;
    case ExpenseCategory.bills:
      return Icons.receipt_long_rounded;
    case ExpenseCategory.entertainment:
      return Icons.movie_rounded;
    case ExpenseCategory.other:
      return Icons.category_rounded;
  }
}

Color categoryColor(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.food:
      return AppColors.categoryAmber;
    case ExpenseCategory.transport:
      return AppColors.categoryTeal;
    case ExpenseCategory.bills:
      return AppColors.categoryPurple;
    case ExpenseCategory.entertainment:
      return AppColors.categoryCoral;
    case ExpenseCategory.other:
      return AppColors.categoryGray;
  }
}