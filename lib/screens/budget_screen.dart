import 'package:flutter/material.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../utils/format_utils.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final ExpenseService _expenseService = ExpenseService();
  final TextEditingController _budgetController = TextEditingController();
  DateTime _selectedMonth = DateTime.now();
  Map<String, dynamic> _budgetStatus = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBudgetStatus();
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _loadBudgetStatus() async {
    setState(() => _isLoading = true);
    
    final status = await _expenseService.getBudgetStatus(
      _selectedMonth.year,
      _selectedMonth.month,
    );
    
    setState(() {
      _budgetStatus = status;
      _isLoading = false;
      if (status['hasBudget']) {
        _budgetController.text = status['budget'].toString();
      }
    });
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (picked != null && picked != _selectedMonth) {
      setState(() {
        _selectedMonth = picked;
      });
      _loadBudgetStatus();
    }
  }

  Future<void> _saveBudget() async {
    final amount = double.tryParse(_budgetController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid budget amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success = await _expenseService.setBudget(
      amount,
      _selectedMonth.year,
      _selectedMonth.month,
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Budget saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _loadBudgetStatus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save budget'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteBudget() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await _expenseService.deleteBudget(
        _selectedMonth.year,
        _selectedMonth.month,
      );

      if (success) {
        _budgetController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Budget deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBudgetStatus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
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

                  // Budget input
                  _buildBudgetInput(),
                  const SizedBox(height: 24),

                  // Budget status
                  if (_budgetStatus['hasBudget']) ...[
                    _buildBudgetStatus(),
                    const SizedBox(height: 24),
                    _buildProgressIndicator(),
                  ] else
                    _buildNoBudgetMessage(),
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

  Widget _buildBudgetInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set Budget',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _budgetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Budget Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
                hintText: 'Enter budget amount',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save Budget'),
                  ),
                ),
                if (_budgetStatus['hasBudget']) ...[
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _deleteBudget,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    ),
                    child: const Icon(Icons.delete),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetStatus() {
    final budget = _budgetStatus['budget'] as double;
    final spent = _budgetStatus['spent'] as double;
    final remaining = _budgetStatus['remaining'] as double;
    final exceeded = _budgetStatus['exceeded'] as bool;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatusRow('Budget', budget, AppColors.primary),
            const Divider(height: 24),
            _buildStatusRow('Spent', spent, exceeded ? Colors.red : AppColors.secondary),
            const Divider(height: 24),
            _buildStatusRow(
              'Remaining',
              remaining,
              exceeded ? Colors.red : Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          FormatUtils.formatCurrency(amount),
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final percentage = _budgetStatus['percentage'] as double;
    final exceeded = _budgetStatus['exceeded'] as bool;
    final approaching = _budgetStatus['approaching'] as bool;

    Color progressColor;
    String statusText;
    IconData statusIcon;

    if (exceeded) {
      progressColor = Colors.red;
      statusText = 'Budget Exceeded!';
      statusIcon = Icons.warning_amber;
    } else if (approaching) {
      progressColor = Colors.orange;
      statusText = 'Approaching Limit';
      statusIcon = Icons.info_outline;
    } else {
      progressColor = Colors.green;
      statusText = 'Within Budget';
      statusIcon = Icons.check_circle_outline;
    }

    return Card(
      elevation: 2,
      color: progressColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(statusIcon, color: progressColor),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${percentage.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoBudgetMessage() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No budget set for this month',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set a budget to track your spending',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
