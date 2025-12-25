/// Category Summary Model
/// Represents expense totals grouped by category
class CategorySummary {
  final String category;
  final double total;
  final int count;

  CategorySummary({
    required this.category,
    required this.total,
    required this.count,
  });

  /// Create CategorySummary from database query result
  factory CategorySummary.fromMap(Map<String, dynamic> map) {
    return CategorySummary(
      category: map['category'] as String,
      total: map['total'] as double,
      count: map['count'] as int,
    );
  }

  @override
  String toString() {
    return 'CategorySummary{category: $category, total: $total, count: $count}';
  }
}
