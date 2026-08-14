import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/data/models/expense_statics.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../view_models/statistics_view_model.dart';

class StatisticsScreenBody extends StatefulWidget {
  const StatisticsScreenBody({super.key});

  @override
  State<StatisticsScreenBody> createState() => _StatisticsScreenBodyState();
}

class _StatisticsScreenBodyState extends State<StatisticsScreenBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsViewModel>().loadStatisticsCommand.execute();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<StatisticsViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Expenses')),
      body: ListenableBuilder(
        listenable: viewModel.loadStatisticsCommand,
        builder: (context, _) {
          final command = viewModel.loadStatisticsCommand;

          if (command.running) {
            return const Center(child: CircularProgressIndicator());
          }

          if (command.error) {
            final result = command.result as Failure;
            return Center(child: Text(result.message));
          }

          if (command.completed) {
            final result = command.result as Success<ExpenseStatics>;
            final stats = result.data;

            if (stats.total == 0) {
              return const Center(child: Text('No expenses yet.'));
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total: ${stats.total.toStringAsFixed(2)} EGP',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: stats.categoryTotal.entries.map((entry) {
                          final percentage = (entry.value / stats.total) * 100;
                          return PieChartSectionData(
                            value: entry.value,
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 80,
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ...stats.categoryTotal.entries.map((entry) {
                    final percentage = (entry.value / stats.total) * 100;
                    return ListTile(
                      title: Text(entry.key.toLabel()),
                      trailing: Text(
                        '${entry.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(0)}%)',
                      ),
                    );
                  }),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
