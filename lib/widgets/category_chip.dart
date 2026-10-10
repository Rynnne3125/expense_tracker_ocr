import 'package:flutter/material.dart';
import '../models/expense_category.dart';

class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: isSelected,
      onSelected: (_) => onTap?.call(),
      avatar: Icon(
        category.icon,
        size: 16,
        color: isSelected ? Colors.white : category.color,
      ),
      label: Text(category.viName),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : Colors.black87,
      ),
      selectedColor: category.color,
      backgroundColor: category.color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? category.color : category.color.withValues(alpha: 0.25),
        ),
      ),
      showCheckmark: false,
    );
  }
}
