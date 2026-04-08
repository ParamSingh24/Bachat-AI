import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import '../theme/app_theme.dart';
import '../providers/expense_provider.dart';
import '../services/pdf_service.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _timeRange = 'Daily';

  // Mock data generator for live wave showing real-time budget spending intensity
  List<FlSpot> _getLiveWaveData() {
    final random = Random();
    return List.generate(20, (index) {
      return FlSpot(index.toDouble(), 100 + random.nextDouble() * 50 + sin(index) * 50);
    });
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = context.watch<ExpenseProvider>().categoryBreakdown;
    final totalExpense = context.watch<ExpenseProvider>().totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: Text("Budget Lab", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 18, color: AppTheme.onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: AppTheme.primary),
            onPressed: () {
               final provider = context.read<ExpenseProvider>();
               PdfService.generateAndPrintReport(provider.expenses, totalExpense);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Live Spending Velocity', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            _buildLiveWaveChart(),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Consumption History', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
                _buildTimeToggle(),
              ],
            ),
            const SizedBox(height: 16),
            _buildBarChart(),
            const SizedBox(height: 32),
            Text('Category Breakdown', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 16)),
            const SizedBox(height: 16),
            if (breakdown.isNotEmpty)
              _buildDonutChart(breakdown, totalExpense)
            else
              const Center(child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text("No data to report."),
              )),
            const SizedBox(height: 120), // Bottom padding for dock
          ],
        ),
      ),
    );
  }

  Widget _buildTimeToggle() {
    final ranges = ['Daily', 'Weekly', 'Monthly'];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ToggleButtons(
        isSelected: ranges.map((r) => r == _timeRange).toList(),
        onPressed: (index) {
          setState(() {
             _timeRange = ranges[index];
          });
        },
        borderRadius: BorderRadius.circular(8),
        selectedColor: AppTheme.surfaceContainerLowest,
        fillColor: AppTheme.primary,
        color: AppTheme.outlineVariant,
        constraints: const BoxConstraints(minHeight: 32, minWidth: 60),
        children: ranges.map((r) => Text(r, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))).toList(),
      ),
    );
  }

  Widget _buildLiveWaveChart() {
    return Container(
      height: 200,
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => const FlLine(color: AppTheme.surfaceContainerLow, strokeWidth: 1)),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (val, meta) => Text('₹${val.toInt()}', style: const TextStyle(fontSize: 10, color: Colors.grey)))),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minX: 0,
          maxX: 19,
          minY: 0,
          maxY: 300,
          lineBarsData: [
            LineChartBarData(
              spots: _getLiveWaveData(),
              isCurved: true,
              color: const Color(0xFF6834EB),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [const Color(0xFF6834EB).withOpacity(0.3), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    final isDaily = _timeRange == 'Daily';
    
    return Container(
      height: 220,
      padding: const EdgeInsets.only(top: 24, bottom: 8, right: 16, left: 16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 200,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul'];
                  final text = isDaily ? days[value.toInt() % 7] : months[value.toInt() % 7];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(text, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            final random = Random();
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: 50 + random.nextDouble() * 100,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6834EB), Color(0xFFC8B7FF)],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                  width: 16,
                  borderRadius: BorderRadius.circular(4),
                )
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildDonutChart(Map<String, double> breakdown, double total) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: breakdown.entries.map((entry) {
                  final perc = (entry.value / total) * 100;
                  return PieChartSectionData(
                    color: _getColorForCategory(entry.key),
                    value: entry.value,
                    title: '${perc.toStringAsFixed(0)}%',
                    radius: 40,
                    titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: breakdown.entries.map((e) {
               final perc = (e.value / total) * 100;
               return Padding(
                 padding: const EdgeInsets.only(bottom: 8.0),
                 child: _buildLegendItem(color: _getColorForCategory(e.key), text: '${e.key} (${perc.toStringAsFixed(0)}%)'),
               );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String text}) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Food': return const Color(0xFFE57373);
      case 'Transport': return const Color(0xFF64B5F6);
      case 'Shopping': return const Color(0xFFFFB74D);
      case 'Bills': return const Color(0xFFba68c8);
      default: return AppTheme.primary;
    }
  }
}
