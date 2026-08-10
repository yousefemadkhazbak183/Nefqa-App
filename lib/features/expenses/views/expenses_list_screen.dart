import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../view_models/expenses_list_view_model.dart';
import '../widgets/expenses_list_screen_body.dart';

class ExpensesListScreen extends StatelessWidget {
  const ExpensesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<ExpensesListViewModel>(),
      child: const ExpensesListScreenBody(),
    );
  }
}
