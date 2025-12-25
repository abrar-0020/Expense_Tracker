import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../utils/format_utils.dart';

/// Add Expense Screen
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({Key? key}) : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ExpenseService _expenseService = ExpenseService();

  String _selectedCategory = AppConstants.categories[0];
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Show date picker with full calendar view
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /// Calculate amount from expression
  void _calculateAmount() {
    final expression = _amountController.text;
    final result = _evaluateExpression(expression);
    if (result != null) {
      _amountController.text = result.toStringAsFixed(2);
    }
  }

  /// Evaluate mathematical expression
  double? _evaluateExpression(String expression) {
    try {
      // Remove spaces
      expression = expression.replaceAll(' ', '');
      
      // If it's just a number, return it
      final simpleNumber = double.tryParse(expression);
      if (simpleNumber != null) return simpleNumber;
      
      // Simple expression evaluator for basic operations
      // This handles +, -, *, / operations
      final sanitized = expression.replaceAll(RegExp(r'[^\d.+\-*/()]'), '');
      if (sanitized.isEmpty) return null;
      
      // Use Function to evaluate (basic calculator)
      // Parse and calculate simple expressions
      return _calculate(sanitized);
    } catch (e) {
      return null;
    }
  }

  /// Basic calculator for expressions
  double? _calculate(String expression) {
    try {
      final tokens = _tokenize(expression);
      if (tokens.isEmpty) return null;
      final parser = _ExpressionParser(tokens);
      return parser.parse();
    } catch (e) {
      return null;
    }
  }

  List<String> _tokenize(String expression) {
    final tokens = <String>[];
    String current = '';
    
    for (int i = 0; i < expression.length; i++) {
      final char = expression[i];
      if ('+-*/()'.contains(char)) {
        if (current.isNotEmpty) {
          tokens.add(current);
          current = '';
        }
        tokens.add(char);
      } else {
        current += char;
      }
    }
    if (current.isNotEmpty) tokens.add(current);
    return tokens;
  }

  /// Save expense
  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Evaluate expression if it's not a simple number
    final amountText = _amountController.text;
    final amount = _evaluateExpression(amountText) ?? double.parse(amountText);
    final description = _descriptionController.text.trim();

    final success = await _expenseService.addExpense(
      amount: amount,
      category: _selectedCategory,
      date: _selectedDate,
      description: description.isEmpty ? null : description,
    );

    setState(() => _isLoading = false);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add expense'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Amount Input
                const Text(
                  'Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildAmountField(),
                const SizedBox(height: 24),

                // Category Selection
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildCategorySelector(),
                const SizedBox(height: 24),

                // Date Selection
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDateSelector(),
                const SizedBox(height: 24),

                // Description Input
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDescriptionField(),
                const SizedBox(height: 32),

                // Save Button
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Amount Input Field
  Widget _buildAmountField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _amountController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[\d.+\-*/()]')),
        ],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.primary, size: 28),
          suffixIcon: IconButton(
            icon: const Icon(Icons.calculate, color: AppColors.secondary),
            tooltip: 'Calculate',
            onPressed: _calculateAmount,
          ),
          hintText: '0.00 or 100+50',
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter amount';
          }
          final result = _evaluateExpression(value);
          if (result == null || result <= 0) {
            return 'Please enter valid amount or expression';
          }
          return null;
        },
      ),
    );
  }

  /// Category Selector Grid
  Widget _buildCategorySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          childAspectRatio: 1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: AppConstants.categories.length,
        itemBuilder: (context, index) {
          final category = AppConstants.categories[index];
          final isSelected = category == _selectedCategory;

          return InkWell(
            onTap: () => setState(() => _selectedCategory = category),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppConstants.categoryColors[category]
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? AppConstants.categoryColors[category]!
                      : AppColors.border,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppConstants.categoryIcons[category],
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Date Selector
  Widget _buildDateSelector() {
    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primary),
            const SizedBox(width: 16),
            Text(
              FormatUtils.formatDate(_selectedDate),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Description Input Field
  Widget _buildDescriptionField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _descriptionController,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        decoration: const InputDecoration(
          hintText: 'Add a note...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  /// Save Button
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Save Expense',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}

/// Expression Parser for Calculator
class _ExpressionParser {
  final List<String> tokens;
  int index = 0;

  _ExpressionParser(this.tokens);

  double parse() {
    return _parseSum();
  }

  double _parseSum() {
    double result = _parseTerm();
    while (index < tokens.length && (tokens[index] == '+' || tokens[index] == '-')) {
      final op = tokens[index++];
      final right = _parseTerm();
      result = op == '+' ? result + right : result - right;
    }
    return result;
  }

  double _parseTerm() {
    double result = _parseFactor();
    while (index < tokens.length && (tokens[index] == '*' || tokens[index] == '/')) {
      final op = tokens[index++];
      final right = _parseFactor();
      result = op == '*' ? result * right : result / right;
    }
    return result;
  }

  double _parseFactor() {
    if (tokens[index] == '(') {
      index++; // skip '('
      final result = _parseSum();
      index++; // skip ')'
      return result;
    }
    return double.parse(tokens[index++]);
  }
}
