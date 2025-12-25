import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/expense.dart';
import '../models/category_summary.dart';
import '../models/budget.dart';

/// Database Helper - Singleton Pattern
/// Handles all SQLite database operations
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  // Private constructor
  DatabaseHelper._internal();

  // Factory constructor returns singleton instance
  factory DatabaseHelper() {
    return _instance;
  }

  /// Get database instance (lazy initialization)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database
  Future<Database> _initDatabase() async {
    // Get database path
    String path = join(await getDatabasesPath(), 'expense_tracker.db');

    // Open database (creates if doesn't exist)
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDatabase,
      onUpgrade: _upgradeDatabase,
    );
  }

  /// Create database tables
  Future<void> _createDatabase(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    // Create index for faster queries by date
    await db.execute('''
      CREATE INDEX idx_date ON expenses(date)
    ''');

    // Create index for category queries
    await db.execute('''
      CREATE INDEX idx_category ON expenses(category)
    ''');

    // Create budgets table
    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL NOT NULL,
        year INTEGER NOT NULL,
        month INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        UNIQUE(year, month)
      )
    ''');
  }

  /// Upgrade database
  Future<void> _upgradeDatabase(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add budgets table for version 2
      await db.execute('''
        CREATE TABLE IF NOT EXISTS budgets (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          amount REAL NOT NULL,
          year INTEGER NOT NULL,
          month INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          UNIQUE(year, month)
        )
      ''');
    }
  }

  /// Insert a new expense
  Future<int> insertExpense(Expense expense) async {
    final db = await database;
    return await db.insert(
      'expenses',
      expense.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get all expenses (sorted by date descending)
  Future<List<Expense>> getAllExpenses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  /// Get expenses for a specific month
  Future<List<Expense>> getExpensesByMonth(int year, int month) async {
    final db = await database;
    
    // Create date range for the month
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.query(
      'expenses',
      where: 'date >= ? AND date <= ?',
      whereArgs: [startDate, endDate],
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) {
      return Expense.fromMap(maps[i]);
    });
  }

  /// Get total expenses for current month
  Future<double> getCurrentMonthTotal() async {
    final now = DateTime.now();
    final expenses = await getExpensesByMonth(now.year, now.month);
    
    return expenses.fold<double>(0.0, (sum, expense) => sum + expense.amount);
  }

  /// Get category-wise summary for current month
  Future<List<CategorySummary>> getCategorySummary(int year, int month) async {
    final db = await database;
    
    final startDate = DateTime(year, month, 1).toIso8601String();
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();

    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        category,
        SUM(amount) as total,
        COUNT(*) as count
      FROM expenses
      WHERE date >= ? AND date <= ?
      GROUP BY category
      ORDER BY total DESC
    ''', [startDate, endDate]);

    return List.generate(maps.length, (i) {
      return CategorySummary.fromMap(maps[i]);
    });
  }

  /// Update an expense
  Future<int> updateExpense(Expense expense) async {
    final db = await database;
    return await db.update(
      'expenses',
      expense.toMap(),
      where: 'id = ?',
      whereArgs: [expense.id],
    );
  }

  /// Delete an expense
  Future<int> deleteExpense(int id) async {
    final db = await database;
    return await db.delete(
      'expenses',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Get total count of expenses
  Future<int> getExpenseCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM expenses');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Close database connection
  Future<void> close() async {
    final db = await database;
    await db.close();
  }

  /// Delete all expenses (for testing/reset)
  Future<void> deleteAllExpenses() async {
    final db = await database;
    await db.delete('expenses');
  }

  // ========== BUDGET OPERATIONS ==========

  /// Set or update budget for a month
  Future<int> setBudget(Budget budget) async {
    final db = await database;
    return await db.insert(
      'budgets',
      budget.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Get budget for specific month
  Future<Budget?> getBudget(int year, int month) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );

    if (maps.isEmpty) return null;
    return Budget.fromMap(maps.first);
  }

  /// Get current month budget
  Future<Budget?> getCurrentMonthBudget() async {
    final now = DateTime.now();
    return await getBudget(now.year, now.month);
  }

  /// Delete budget for specific month
  Future<int> deleteBudget(int year, int month) async {
    final db = await database;
    return await db.delete(
      'budgets',
      where: 'year = ? AND month = ?',
      whereArgs: [year, month],
    );
  }

  /// Get all budgets
  Future<List<Budget>> getAllBudgets() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'budgets',
      orderBy: 'year DESC, month DESC',
    );

    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }
}

