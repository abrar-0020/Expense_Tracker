/// Expense Model
/// Represents a single expense record
class Expense {
  final int? id; // Auto-increment ID from SQLite
  final double amount;
  final String category;
  final DateTime date;
  final String? description;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  /// Convert Expense object to Map for database insertion
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  /// Create Expense object from database Map
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String?,
    );
  }

  /// Create a copy of expense with modified fields
  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }

  @override
  String toString() {
    return 'Expense{id: $id, amount: $amount, category: $category, date: $date, description: $description}';
  }
}
