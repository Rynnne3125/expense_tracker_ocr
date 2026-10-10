import 'package:flutter/material.dart';

class CropViewfinderOverlay extends StatefulWidget {
  final VoidCallback? onCapture;
  final VoidCallback? onFlashToggle;
  final VoidCallback? onPickGallery;
  final bool isFlashOn;
  final Widget? backgroundWidget;

  const CropViewfinderOverlay({
    super.key,
    this.onCapture,
    this.onFlashToggle,
    this.onPickGallery,
    this.isFlashOn = false,
    this.backgroundWidget,
  });

  @override
  State<CropViewfinderOverlay> createState() => _CropViewfinderOverlayState();
}

class _CropViewfinderOverlayState extends State<CropViewfinderOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _laserController;
  late Animation<double> _laserAnimation;

  Offset? _focusPoint;
  bool _showFocusRing = false;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _laserAnimation = CurvedAnimation(
      parent: _laserController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  void _handleFocusTap(TapDownDetails details) {
    setState(() {
      _focusPoint = details.localPosition;
      _showFocusRing = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _showFocusRing = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleFocusTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background (camera preview or placeholder image)
          if (widget.backgroundWidget != null) widget.backgroundWidget!,

          // Semi-transparent cutout overlay with corner brackets
          CustomPaint(
            painter: _ViewfinderPainter(),
          ),

          // Animated Scanning Laser Line
          AnimatedBuilder(
            animation: _laserAnimation,
            builder: (context, child) {
              return CustomPaint(
                painter: _ScanningLaserPainter(progress: _laserAnimation.value),
              );
            },
          ),

          // Focus indicator animation on tap
          if (_showFocusRing && _focusPoint != null)
            Positioned(
              left: _focusPoint!.dx - 32,
              top: _focusPoint!.dy - 32,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 1.4, end: 0.9),
                duration: const Duration(milliseconds: 350),
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.amber, width: 2),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: const Center(
                        child: Icon(Icons.add, color: Colors.amber, size: 16),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Top action buttons: Flash toggle and Hint
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton.filledTonal(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.crop_free_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Căn chỉnh hóa đơn',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: widget.onFlashToggle,
                  icon: Icon(
                    widget.isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: widget.isFlashOn ? Colors.amber : Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // Bottom instruction text
          Positioned(
            bottom: 120,
            left: 24,
            right: 24,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Đặt hóa đơn phẳng phiu trong khung • Chạm để lấy nét',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Crop frame box dimensions
    final boxWidth = size.width * 0.85;
    final boxHeight = size.height * 0.62;
    final boxLeft = (size.width - boxWidth) / 2;
    final boxTop = (size.height - boxHeight) / 2.3;
    final cropRect = Rect.fromLTWH(boxLeft, boxTop, boxWidth, boxHeight);

    // Dark overlay with cutout
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(cropRect, const Radius.circular(16)));
    final overlayPath = Path.combine(PathOperation.difference, backgroundPath, cutoutPath);

    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    canvas.drawPath(overlayPath, overlayPaint);

    // Frame border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(cropRect, const Radius.circular(16)),
      borderPaint,
    );

    // 4 High-tech corner brackets
    final cornerPaint = Paint()
      ..color = const Color(0xFF00E676) // Electric green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    const double cornerLen = 28.0;

    // Top-Left
    canvas.drawLine(Offset(boxLeft, boxTop + cornerLen), Offset(boxLeft, boxTop + 14), cornerPaint);
    canvas.drawLine(Offset(boxLeft + 14, boxTop), Offset(boxLeft + cornerLen, boxTop), cornerPaint);
    // Top-Right
    canvas.drawLine(Offset(boxLeft + boxWidth - cornerLen, boxTop), Offset(boxLeft + boxWidth - 14, boxTop), cornerPaint);
    canvas.drawLine(Offset(boxLeft + boxWidth, boxTop + 14), Offset(boxLeft + boxWidth, boxTop + cornerLen), cornerPaint);
    // Bottom-Left
    canvas.drawLine(Offset(boxLeft, boxTop + boxHeight - cornerLen), Offset(boxLeft, boxTop + boxHeight - 14), cornerPaint);
    canvas.drawLine(Offset(boxLeft + 14, boxTop + boxHeight), Offset(boxLeft + cornerLen, boxTop + boxHeight), cornerPaint);
    // Bottom-Right
    canvas.drawLine(Offset(boxLeft + boxWidth - cornerLen, boxTop + boxHeight), Offset(boxLeft + boxWidth - 14, boxTop + boxHeight), cornerPaint);
    canvas.drawLine(Offset(boxLeft + boxWidth, boxTop + boxHeight - 14), Offset(boxLeft + boxWidth, boxTop + boxHeight - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ScanningLaserPainter extends CustomPainter {
  final double progress;

  _ScanningLaserPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final boxWidth = size.width * 0.85;
    final boxHeight = size.height * 0.62;
    final boxLeft = (size.width - boxWidth) / 2;
    final boxTop = (size.height - boxHeight) / 2.3;

    final laserY = boxTop + (boxHeight * progress);

    final linePaint = Paint()
      ..color = const Color(0xFF00E676)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(boxLeft + 6, laserY),
      Offset(boxLeft + boxWidth - 6, laserY),
      linePaint,
    );

    // Glowing laser beam gradient
    final beamRect = Rect.fromLTWH(boxLeft + 6, laserY - 18, boxWidth - 12, 36);
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E676).withValues(alpha: 0.0),
          const Color(0xFF00E676).withValues(alpha: 0.25),
          const Color(0xFF00E676).withValues(alpha: 0.0),
        ],
      ).createShader(beamRect);

    canvas.drawRect(beamRect, beamPaint);
  }

  @override
  bool shouldRepaint(covariant _ScanningLaserPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
