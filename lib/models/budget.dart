/// Budget Model
class Budget {
  final int? id;
  final double amount;
  final int year;
  final int month;
  final DateTime createdAt;

  Budget({
    this.id,
    required this.amount,
    required this.year,
    required this.month,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert from database map
  factory Budget.fromMap(Map<String, dynamic> map) {
    return Budget(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      year: map['year'] as int,
      month: map['month'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert to database map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'year': year,
      'month': month,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Calculate budget remaining
  double remaining(double spent) {
    return amount - spent;
  }

  /// Calculate percentage spent
  double percentageSpent(double spent) {
    if (amount == 0) return 0;
    return (spent / amount) * 100;
  }

  /// Check if budget exceeded
  bool isExceeded(double spent) {
    return spent > amount;
  }

  /// Check if approaching limit (80%)
  bool isApproachingLimit(double spent) {
    return percentageSpent(spent) >= 80;
  }
}
