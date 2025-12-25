import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../utils/format_utils.dart';
import '../models/category_summary.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  final ExpenseService _expenseService = ExpenseService();
  DateTime _selectedMonth = DateTime.now();
  List<CategorySummary> _categorySummary = [];
  double _totalAmount = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);
    
    final summary = await _expenseService.getCategorySummaryForMonth(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    
    final total = summary.fold<double>(0.0, (sum, cat) => sum + cat.total);
    
    setState(() {
      _categorySummary = summary;
      _totalAmount = total;
      _isLoading = false;
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadAnalytics();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month selector
                  _buildMonthSelector(),
                  const SizedBox(height: 24),

                  // Total amount card
                  _buildTotalCard(),
                  const SizedBox(height: 24),

                  // Pie chart
                  if (_categorySummary.isNotEmpty) ...[
                    _buildPieChartCard(),
                    const SizedBox(height: 24),
                    
                    // Bar chart
                    _buildBarChartCard(),
                    const SizedBox(height: 24),
                    
                    // Category list
                    _buildCategoryList(),
                  ] else
                    _buildNoDataMessage(),
                ],
              ),
            ),
    );
  }

  Widget _buildMonthSelector() {
    final monthYear = FormatUtils.formatMonthYear(_selectedMonth);
    
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _selectMonth(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.calendar_month, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                monthYear,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Total Expenses',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            FormatUtils.formatCurrency(_totalAmount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_categorySummary.length} categories',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: _getPieSections(),
                  centerSpaceRadius: 60,
                  sectionsSpace: 2,
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieSections() {
    return _categorySummary.asMap().entries.map((entry) {
      final category = entry.value;
      final percentage = (category.total / _totalAmount) * 100;
      final color = AppConstants.categoryColors[category.category] ?? Colors.grey;

      return PieChartSectionData(
        color: color,
        value: category.total,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildBarChartCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: _categorySummary.isEmpty
                      ? 100
                      : _categorySummary.map((e) => e.total).reduce((a, b) => a > b ? a : b) * 1.2,
                  barGroups: _getBarGroups(),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < _categorySummary.length) {
                            final category = _categorySummary[value.toInt()].category;
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                category.length > 4 ? '${category.substring(0, 3)}.' : category,
                                style: const TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            FormatUtils.formatCompactCurrency(value),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: _categorySummary.isEmpty ? 20 : null,
                  ),
                  borderData: FlBorderData(show: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return _categorySummary.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final color = AppConstants.categoryColors[category.category] ?? Colors.grey;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: category.total,
            color: color,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildCategoryList() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Breakdown',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._categorySummary.map((category) => _buildCategoryItem(category)),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryItem(CategorySummary category) {
    final percentage = (category.total / _totalAmount) * 100;
    final color = AppConstants.categoryColors[category.category] ?? Colors.grey;
    final icon = AppConstants.categoryIcons[category.category] ?? Icons.category;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.category,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${category.count} expenses',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FormatUtils.formatCurrency(category.total),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.bar_chart_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses for this month',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add expenses to see analytics',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
