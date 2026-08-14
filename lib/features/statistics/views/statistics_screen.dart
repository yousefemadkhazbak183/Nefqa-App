import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/di/service_locator.dart';
import '../view_models/statistics_view_model.dart';
import '../widgets/statistics_screen_body.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => getIt<StatisticsViewModel>(),
      child: const StatisticsScreenBody(),
    );
  }
}
