import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../utils/constants.dart';
import '../utils/format_utils.dart';

/// Expense Card Widget - Reusable card for displaying expense
class ExpenseCard extends StatelessWidget {
  final Expense expense;
  final VoidCallback? onDelete;
  final VoidCallback? onDuplicate;

  const ExpenseCard({
    Key? key,
    required this.expense,
    this.onDelete,
    this.onDuplicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryColor = AppConstants.categoryColors[expense.category] ??
        AppColors.textSecondary;
    final categoryIcon =
        AppConstants.categoryIcons[expense.category] ?? Icons.category;

    return Dismissible(
      key: Key(expense.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 28,
        ),
      ),
      confirmDismiss: (direction) async {
        if (onDelete != null) {
          onDelete!();
        }
        return false; // Don't auto-dismiss, let parent handle it
      },
      child: Container(
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
        child: Row(
          children: [
            // Category Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                categoryIcon,
                color: categoryColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),

            // Expense Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.category,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    FormatUtils.formatDate(expense.date),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (expense.description != null &&
                      expense.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      expense.description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Amount and Actions
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  FormatUtils.formatCurrency(expense.amount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onDuplicate != null) ...[
                      InkWell(
                        onTap: onDuplicate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.copy, size: 14, color: AppColors.secondary),
                              SizedBox(width: 4),
                              Text(
                                'Duplicate',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (onDelete != null)
                      InkWell(
                        onTap: onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.error,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
