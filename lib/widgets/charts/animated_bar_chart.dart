import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AnimatedWeeklyBarChart extends StatefulWidget {
  final List<double> dayTotals; // Exactly 7 values: Mon..Sun

  const AnimatedWeeklyBarChart({
    super.key,
    required this.dayTotals,
  });

  @override
  State<AnimatedWeeklyBarChart> createState() => _AnimatedWeeklyBarChartState();
}

class _AnimatedWeeklyBarChartState extends State<AnimatedWeeklyBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int? _selectedBarIndex;

  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant AnimatedWeeklyBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap(Offset localPosition, Size size) {
    // 7 columns
    final chartLeft = 24.0;
    final chartRight = size.width - 16.0;
    final chartWidth = chartRight - chartLeft;
    final columnWidth = chartWidth / 7;

    if (localPosition.dx < chartLeft || localPosition.dx > chartRight) {
      setState(() => _selectedBarIndex = null);
      return;
    }

    final index = ((localPosition.dx - chartLeft) / columnWidth).floor();
    if (index >= 0 && index < 7) {
      setState(() {
        if (_selectedBarIndex == index) {
          _selectedBarIndex = null;
        } else {
          _selectedBarIndex = index;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.compactCurrency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final fullCurrencyFormatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    final todayIndex = (DateTime.now().weekday - 1) % 7;
    final maxAmount = widget.dayTotals.isEmpty
        ? 0.0
        : widget.dayTotals.reduce(math.max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedBarIndex != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 6),
                Text(
                  'Thứ ${_selectedBarIndex == 6 ? "Chủ Nhật" : "${_selectedBarIndex! + 2}"}: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Text(
                  fullCurrencyFormatter.format(widget.dayTotals[_selectedBarIndex!]),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 180,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, 180);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => _handleTap(details.localPosition, size),
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: size,
                      painter: _WeeklyBarChartPainter(
                        dayTotals: widget.dayTotals,
                        dayLabels: _dayLabels,
                        maxAmount: maxAmount,
                        progress: _animation.value,
                        todayIndex: todayIndex,
                        selectedIndex: _selectedBarIndex,
                        primaryColor: Theme.of(context).primaryColor,
                        compactFormatter: currencyFormatter,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _WeeklyBarChartPainter extends CustomPainter {
  final List<double> dayTotals;
  final List<String> dayLabels;
  final double maxAmount;
  final double progress;
  final int todayIndex;
  final int? selectedIndex;
  final Color primaryColor;
  final NumberFormat compactFormatter;

  _WeeklyBarChartPainter({
    required this.dayTotals,
    required this.dayLabels,
    required this.maxAmount,
    required this.progress,
    required this.todayIndex,
    required this.selectedIndex,
    required this.primaryColor,
    required this.compactFormatter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const double paddingLeft = 32.0;
    const double paddingRight = 12.0;
    const double paddingBottom = 28.0;
    const double paddingTop = 20.0;

    final chartWidth = size.width - paddingLeft - paddingRight;
    final chartHeight = size.height - paddingTop - paddingBottom;
    final baselineY = size.height - paddingBottom;

    // 1. Draw horizontal grid lines
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;

    final textStyle = TextStyle(
      color: Colors.grey.shade500,
      fontSize: 10,
      fontWeight: FontWeight.w500,
    );

    const int gridSteps = 3;
    final effectiveMax = maxAmount > 0 ? maxAmount : 100000.0;

    for (int i = 0; i <= gridSteps; i++) {
      final y = baselineY - (chartHeight / gridSteps) * i;
      canvas.drawLine(
        Offset(paddingLeft, y),
        Offset(size.width - paddingRight, y),
        gridPaint,
      );

      // Draw Y-axis value label
      final val = (effectiveMax / gridSteps) * i;
      final textSpan = TextSpan(
        text: compactFormatter.format(val),
        style: textStyle,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      textPainter.paint(
        canvas,
        Offset(0, y - (textPainter.height / 2)),
      );
    }

    // 2. Draw 7 Bars
    final columnWidth = chartWidth / 7;
    final barWidth = math.min(22.0, columnWidth * 0.55);

    for (int i = 0; i < 7; i++) {
      final amount = i < dayTotals.length ? dayTotals[i] : 0.0;
      final normalizedHeight = effectiveMax > 0
          ? (amount / effectiveMax) * chartHeight
          : 0.0;
      final barHeight = normalizedHeight * progress;

      final centerX = paddingLeft + (i * columnWidth) + (columnWidth / 2);
      final barLeft = centerX - (barWidth / 2);
      final barTop = baselineY - barHeight;

      final isToday = i == todayIndex;
      final isSelected = i == selectedIndex;

      // Draw highlight column background if selected
      if (isSelected) {
        final highlightRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            centerX - (columnWidth * 0.45),
            paddingTop - 6,
            columnWidth * 0.9,
            chartHeight + 8,
          ),
          const Radius.circular(8),
        );
        final highlightPaint = Paint()
          ..color = primaryColor.withValues(alpha: 0.08);
        canvas.drawRRect(highlightRect, highlightPaint);
      }

      // Bar gradient paint
      final barRect = Rect.fromLTWH(barLeft, barTop, barWidth, barHeight);
      final Color startColor = isSelected
          ? const Color(0xFF673AB7) // Deep accent
          : isToday
              ? primaryColor
              : const Color(0xFF90CAF9);
      final Color endColor = isSelected
          ? const Color(0xFF9C27B0)
          : isToday
              ? primaryColor.withValues(alpha: 0.7)
              : const Color(0xFF64B5F6);

      final barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [startColor, endColor],
        ).createShader(barRect);

      // Draw bar if height > 0
      if (barHeight > 2) {
        final rrect = RRect.fromRectAndCorners(
          barRect,
          topLeft: const Radius.circular(6),
          topRight: const Radius.circular(6),
        );
        canvas.drawRRect(rrect, barPaint);
      } else {
        // Draw small dot / placeholder baseline pill for 0 amount
        final emptyPaint = Paint()
          ..color = Colors.grey.withValues(alpha: 0.25);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(barLeft, baselineY - 4, barWidth, 4),
            const Radius.circular(2),
          ),
          emptyPaint,
        );
      }

      // 3. Draw X-axis day label (T2..CN)
      final labelSpan = TextSpan(
        text: dayLabels[i],
        style: TextStyle(
          color: isSelected
              ? primaryColor
              : isToday
                  ? primaryColor
                  : Colors.grey.shade600,
          fontSize: 11,
          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: ui.TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(centerX - (labelPainter.width / 2), baselineY + 6),
      );

      // Small today indicator dot
      if (isToday) {
        final dotPaint = Paint()..color = primaryColor;
        canvas.drawCircle(Offset(centerX, baselineY + 22), 2.5, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WeeklyBarChartPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.maxAmount != maxAmount ||
        oldDelegate.dayTotals != dayTotals;
  }
}
