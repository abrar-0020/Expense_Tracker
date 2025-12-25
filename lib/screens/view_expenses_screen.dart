import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/expense_service.dart';
import '../utils/constants.dart';
import '../utils/format_utils.dart';
import '../widgets/expense_card.dart';

/// View Expenses Screen - List of all expenses
class ViewExpensesScreen extends StatefulWidget {
  const ViewExpensesScreen({Key? key}) : super(key: key);

  @override
  State<ViewExpensesScreen> createState() => _ViewExpensesScreenState();
}

class _ViewExpensesScreenState extends State<ViewExpensesScreen> {
  final ExpenseService _expenseService = ExpenseService();
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  bool _isLoading = true;
  String _sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Load all expenses
  Future<void> _loadExpenses() async {
    setState(() => _isLoading = true);
    
    final expenses = await _expenseService.getAllExpenses();
    
    setState(() {
      _expenses = expenses;
      _filterAndSortExpenses();
      _isLoading = false;
    });
  }

  /// Filter and sort expenses
  void _filterAndSortExpenses() {
    // Apply search filter
    if (_searchQuery.isEmpty) {
      _filteredExpenses = List.from(_expenses);
    } else {
      _filteredExpenses = _expenses.where((expense) {
        final query = _searchQuery.toLowerCase();
        return expense.category.toLowerCase().contains(query) ||
               (expense.description?.toLowerCase().contains(query) ?? false) ||
               expense.amount.toString().contains(query);
      }).toList();
    }
    
    // Apply sorting
    _sortExpenses();
  }

  /// Sort expenses based on selected criteria
  void _sortExpenses() {
    switch (_sortBy) {
      case 'date_desc':
        _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
        break;
      case 'date_asc':
        _filteredExpenses.sort((a, b) => a.date.compareTo(b.date));
        break;
      case 'amount_desc':
        _filteredExpenses.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case 'amount_asc':
        _filteredExpenses.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
  }

  /// Show sort options
  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Newest First', 'date_desc', Icons.arrow_downward),
            _buildSortOption('Oldest First', 'date_asc', Icons.arrow_upward),
            _buildSortOption('Highest Amount', 'amount_desc', Icons.trending_down),
            _buildSortOption('Lowest Amount', 'amount_asc', Icons.trending_up),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String title, String value, IconData icon) {
    final isSelected = _sortBy == value;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: AppColors.primary)
          : null,
      onTap: () {
        setState(() {
          _sortBy = value;
          _sortExpenses();
        });
        Navigator.pop(context);
      },
    );
  }

  /// Delete expense with confirmation
  Future<void> _deleteExpense(Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Expense'),
        content: const Text('Are you sure you want to delete this expense?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && expense.id != null) {
      final success = await _expenseService.deleteExpense(expense.id!);
      
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Expense deleted'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          _loadExpenses();
        }
      }
    }
  }

  /// Duplicate expense
  Future<void> _duplicateExpense(Expense expense) async {
    final success = await _expenseService.addExpense(
      amount: expense.amount,
      category: expense.category,
      date: DateTime.now(), // Use current date for duplicate
      description: expense.description != null 
        ? '${expense.description} (Copy)' 
        : 'Copy',
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Expense duplicated successfully'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'All Expenses',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort, color: Colors.white),
            tooltip: 'Sort',
            onPressed: _showSortOptions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                        _filterAndSortExpenses();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by category, description, amount...',
                      prefixIcon: Icon(Icons.search, color: theme.iconTheme.color),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _filterAndSortExpenses();
                                });
                              },
                            )
                          : null,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                // Expenses List
                Expanded(
                  child: _filteredExpenses.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadExpenses,
                          color: theme.primaryColor,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredExpenses.length,
                            itemBuilder: (context, index) {
                              final expense = _filteredExpenses[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ExpenseCard(
                                  expense: expense,
                                  onDelete: () => _deleteExpense(expense),
                                  onDuplicate: () => _duplicateExpense(expense),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  /// Empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 100,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No expenses yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
