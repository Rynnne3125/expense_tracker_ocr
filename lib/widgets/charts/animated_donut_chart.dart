import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/expense_category.dart';

class AnimatedDonutChart extends StatefulWidget {
  final Map<ExpenseCategory, double> categoryTotals;
  final double totalAmount;

  const AnimatedDonutChart({
    super.key,
    required this.categoryTotals,
    required this.totalAmount,
  });

  @override
  State<AnimatedDonutChart> createState() => _AnimatedDonutChartState();
}

class _AnimatedDonutChartState extends State<AnimatedDonutChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ExpenseCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedDonutChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalAmount != widget.totalAmount) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    if (widget.totalAmount <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final dx = localPosition.dx - center.dx;
    final dy = localPosition.dy - center.dy;
    final distance = math.sqrt(dx * dx + dy * dy);

    final radius = math.min(size.width, size.height) / 2;
    final innerRadius = radius * 0.55;
    final outerRadius = radius * 0.95;

    // Check if tap fell inside the donut ring
    if (distance < innerRadius || distance > outerRadius + 15) {
      setState(() => _selectedCategory = null);
      return;
    }

    // Calculate angle in radians [0, 2*pi] starting from top (-pi/2)
    var angle = math.atan2(dy, dx);
    angle += math.pi / 2; // Shift so 0 is at top
    if (angle < 0) angle += 2 * math.pi;

    double accumulatedAngle = 0;
    ExpenseCategory? tappedCat;

    for (final entry in widget.categoryTotals.entries) {
      if (entry.value <= 0) continue;
      final sweep = (entry.value / widget.totalAmount) * 2 * math.pi;
      if (angle >= accumulatedAngle && angle <= accumulatedAngle + sweep) {
        tappedCat = entry.key;
        break;
      }
      accumulatedAngle += sweep;
    }

    setState(() {
      if (_selectedCategory == tappedCat) {
        _selectedCategory = null;
      } else {
        _selectedCategory = tappedCat;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final isZero = widget.totalAmount <= 0;

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, 240);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleTap(details.localPosition, size),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return CustomPaint(
                          size: size,
                          painter: _DonutChartPainter(
                            categoryTotals: widget.categoryTotals,
                            totalAmount: widget.totalAmount,
                            progress: _animation.value,
                            selectedCategory: _selectedCategory,
                          ),
                        );
                      },
                    ),
                    // Center Text Content
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _selectedCategory != null
                              ? _selectedCategory!.viName
                              : 'Tổng phân bổ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _selectedCategory != null
                                ? _selectedCategory!.color
                                : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormatter.format(
                            _selectedCategory != null
                                ? (widget.categoryTotals[_selectedCategory] ?? 0)
                                : widget.totalAmount,
                          ),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        if (_selectedCategory != null && !isZero) ...[
                          const SizedBox(height: 2),
                          Text(
                            '${(((widget.categoryTotals[_selectedCategory] ?? 0) / widget.totalAmount) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: _selectedCategory!.color,
                            ),
                          ),
                        ] else ...[
                          const SizedBox(height: 2),
                          Text(
                            'Chạm để xem chi tiết',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Interactive Category Legends
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: widget.categoryTotals.entries.map((entry) {
            final cat = entry.key;
            final amount = entry.value;
            final isSelected = _selectedCategory == cat;
            final percent = isZero ? 0.0 : (amount / widget.totalAmount) * 100;

            return InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                setState(() {
                  _selectedCategory = isSelected ? null : cat;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? cat.color.withValues(alpha: 0.18)
                      : Colors.grey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? cat.color
                        : Colors.grey.withValues(alpha: 0.2),
                    width: isSelected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: cat.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat.viName,
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? cat.color : Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percent.toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final Map<ExpenseCategory, double> categoryTotals;
  final double totalAmount;
  final double progress;
  final ExpenseCategory? selectedCategory;

  _DonutChartPainter({
    required this.categoryTotals,
    required this.totalAmount,
    required this.progress,
    required this.selectedCategory,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 * 0.78;

    // Draw empty background track
    final trackPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26;
    canvas.drawCircle(center, radius, trackPaint);

    if (totalAmount <= 0) return;

    // Starting from top: -pi/2
    double startAngle = -math.pi / 2;
    const double gapAngle = 0.04; // Gap between arcs in radians

    for (final entry in categoryTotals.entries) {
      final category = entry.key;
      final amount = entry.value;
      if (amount <= 0) continue;

      final isSelected = selectedCategory == category;
      final sliceSweep = (amount / totalAmount) * 2 * math.pi;
      final currentSweep = sliceSweep * progress;

      if (currentSweep <= 0.001) continue;

      // Adjust for slight slice gap if multiple categories exist
      final adjustedSweep = math.max(0.01, currentSweep - gapAngle);

      final sliceRadius = isSelected ? radius + 4 : radius;
      final strokeWidth = isSelected ? 34.0 : 26.0;

      // Draw shadow for selected slice
      if (isSelected) {
        final shadowPaint = Paint()
          ..color = category.color.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth + 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: sliceRadius),
          startAngle + (gapAngle / 2),
          adjustedSweep,
          false,
          shadowPaint,
        );
      }

      final slicePaint = Paint()
        ..color = category.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: sliceRadius),
        startAngle + (gapAngle / 2),
        adjustedSweep,
        false,
        slicePaint,
      );

      startAngle += currentSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedCategory != selectedCategory ||
        oldDelegate.totalAmount != totalAmount ||
        oldDelegate.categoryTotals != categoryTotals;
  }
}
