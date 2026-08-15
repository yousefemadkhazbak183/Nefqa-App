import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:nefqa/core/enum/expense_category.dart';
import 'package:nefqa/data/models/expense_statics.dart';
import 'package:provider/provider.dart';
import '../../../core/network/result.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_notifier.dart';
import '../../../core/widgets/category_style.dart';
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
    final themeNotifier = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        actions: [
          IconButton(
            icon: Icon(
              themeNotifier.isDark
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            onPressed: () => context.read<ThemeNotifier>().toggleTheme(),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: viewModel.loadStatisticsCommand,
        builder: (context, _) {
          final command = viewModel.loadStatisticsCommand;

          if (command.running) {
            return const Center(child: CircularProgressIndicator());
          }
          if (command.error) {
            final result = command.result as Failure;
            return Center(
              child: Text(
                result.message,
                style: TextStyle(color: AppColors.textSecondary(context)),
              ),
            );
          }

          if (command.completed) {
            final stats = (command.result as Success<ExpenseStatics>).data;

            if (stats.total == 0) {
              return Center(
                child: Text(
                  'No expenses yet.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${stats.total.toStringAsFixed(0)} EGP',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total spent',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 3,
                        centerSpaceRadius: 50,
                        sections: stats.categoryTotal.entries.map((entry) {
                          final percentage = (entry.value / stats.total) * 100;
                          return PieChartSectionData(
                            value: entry.value,
                            color: categoryColor(entry.key),
                            title: '${percentage.toStringAsFixed(0)}%',
                            radius: 55,
                            titleStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.background(context),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView.separated(
                      itemCount: stats.categoryTotal.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: AppColors.surfaceElevated(context),
                      ),
                      itemBuilder: (context, index) {
                        final entry = stats.categoryTotal.entries.elementAt(
                          index,
                        );
                        final percentage = (entry.value / stats.total) * 100;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: categoryColor(entry.key),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  entry.key.toLabel(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              Text(
                                '${entry.value.toStringAsFixed(0)} EGP',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${percentage.toStringAsFixed(0)}%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted(context),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
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
