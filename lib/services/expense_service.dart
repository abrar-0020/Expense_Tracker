import '../database/database_helper.dart';
import '../models/expense.dart';
import '../models/category_summary.dart';
import '../models/budget.dart';

/// Expense Service
/// Business logic layer between UI and Database
class ExpenseService {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  /// Add a new expense
  Future<bool> addExpense({
    required double amount,
    required String category,
    required DateTime date,
    String? description,
  }) async {
    try {
      final expense = Expense(
        amount: amount,
        category: category,
        date: date,
        description: description,
      );

      await _dbHelper.insertExpense(expense);
      return true;
    } catch (e) {
      print('Error adding expense: $e');
      return false;
    }
  }

  /// Get all expenses
  Future<List<Expense>> getAllExpenses() async {
    try {
      return await _dbHelper.getAllExpenses();
    } catch (e) {
      print('Error fetching expenses: $e');
      return [];
    }
  }

  /// Get expenses for specific month
  Future<List<Expense>> getMonthlyExpenses(int year, int month) async {
    try {
      return await _dbHelper.getExpensesByMonth(year, month);
    } catch (e) {
      print('Error fetching monthly expenses: $e');
      return [];
    }
  }

  /// Get current month total
  Future<double> getCurrentMonthTotal() async {
    try {
      return await _dbHelper.getCurrentMonthTotal();
    } catch (e) {
      print('Error calculating monthly total: $e');
      return 0.0;
    }
  }

  /// Get category summary for current month
  Future<List<CategorySummary>> getMonthlyCategorySummary() async {
    try {
      final now = DateTime.now();
      return await _dbHelper.getCategorySummary(now.year, now.month);
    } catch (e) {
      print('Error fetching category summary: $e');
      return [];
    }
  }

  /// Get category summary for specific month and year
  Future<List<CategorySummary>> getCategorySummaryForMonth(int year, int month) async {
    try {
      return await _dbHelper.getCategorySummary(year, month);
    } catch (e) {
      print('Error fetching category summary: $e');
      return [];
    }
  }

  /// Delete an expense
  Future<bool> deleteExpense(int id) async {
    try {
      await _dbHelper.deleteExpense(id);
      return true;
    } catch (e) {
      print('Error deleting expense: $e');
      return false;
    }
  }

  /// Get total expense count
  Future<int> getTotalExpenseCount() async {
    try {
      return await _dbHelper.getExpenseCount();
    } catch (e) {
      print('Error getting expense count: $e');
      return 0;
    }
  }

  /// Delete all expenses
  Future<bool> deleteAllExpenses() async {
    try {
      await _dbHelper.deleteAllExpenses();
      return true;
    } catch (e) {
      print('Error deleting all expenses: $e');
      return false;
    }
  }

  // ========== BUDGET OPERATIONS ==========

  /// Set budget for a month
  Future<bool> setBudget(double amount, int year, int month) async {
    try {
      final budget = Budget(
        amount: amount,
        year: year,
        month: month,
      );
      await _dbHelper.setBudget(budget);
      return true;
    } catch (e) {
      print('Error setting budget: $e');
      return false;
    }
  }

  /// Get budget for specific month
  Future<Budget?> getBudget(int year, int month) async {
    try {
      return await _dbHelper.getBudget(year, month);
    } catch (e) {
      print('Error getting budget: $e');
      return null;
    }
  }

  /// Get current month budget
  Future<Budget?> getCurrentMonthBudget() async {
    try {
      return await _dbHelper.getCurrentMonthBudget();
    } catch (e) {
      print('Error getting current month budget: $e');
      return null;
    }
  }

  /// Delete budget
  Future<bool> deleteBudget(int year, int month) async {
    try {
      await _dbHelper.deleteBudget(year, month);
      return true;
    } catch (e) {
      print('Error deleting budget: $e');
      return false;
    }
  }

  /// Get budget status (remaining, percentage, etc.)
  Future<Map<String, dynamic>> getBudgetStatus(int year, int month) async {
    try {
      final budget = await _dbHelper.getBudget(year, month);
      if (budget == null) {
        return {
          'hasBudget': false,
          'budget': 0.0,
          'spent': 0.0,
          'remaining': 0.0,
          'percentage': 0.0,
          'exceeded': false,
          'approaching': false,
        };
      }

      final expenses = await _dbHelper.getExpensesByMonth(year, month);
      final spent = expenses.fold<double>(0.0, (sum, exp) => sum + exp.amount);

      return {
        'hasBudget': true,
        'budget': budget.amount,
        'spent': spent,
        'remaining': budget.remaining(spent),
        'percentage': budget.percentageSpent(spent),
        'exceeded': budget.isExceeded(spent),
        'approaching': budget.isApproachingLimit(spent),
      };
    } catch (e) {
      print('Error getting budget status: $e');
      return {
        'hasBudget': false,
        'budget': 0.0,
        'spent': 0.0,
        'remaining': 0.0,
        'percentage': 0.0,
        'exceeded': false,
        'approaching': false,
      };
    }
  }
}
