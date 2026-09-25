import 'dart:math' as math;
import 'package:flutter/material.dart';

/// CustomPainter that renders a smooth, winding snake-like track with 3D horizon perspective.
class TimelineTrackPainter extends CustomPainter {
  final double scrollOffset;
  final double itemSpacing;
  final int totalCount;
  final double amplitude;
  final Color baseColor;
  final Color accentColor;
  final bool isDark;
  final double? focusY;
  final double? horizonY;

  TimelineTrackPainter({
    required this.scrollOffset,
    required this.itemSpacing,
    required this.totalCount,
    required this.amplitude,
    required this.baseColor,
    required this.accentColor,
    required this.isDark,
    this.focusY,
    this.horizonY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalCount == 0) return;

    final centerX = size.width / 2;
    final horizonY = this.horizonY ?? (size.height < 500 ? 6.0 : 50.0);
    final focusY = this.focusY ?? (size.height < 500 ? 16.0 : size.height * 0.48);

    // Glowing track background paint
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..color = accentColor.withValues(alpha: isDark ? 0.12 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Primary track stroke paint
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accentColor.withValues(alpha: 0.1),
          accentColor.withValues(alpha: 0.8),
          accentColor,
          accentColor.withValues(alpha: 0.4),
        ],
        stops: const [0.0, 0.25, 0.6, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    bool isFirst = true;

    final maxTrackOffset = (totalCount - 1) * itemSpacing;
    final effectiveScrollOffset = math.min(scrollOffset, maxTrackOffset);

    // Sample along visible Y space
    final step = 8.0;
    for (double y = horizonY; y <= size.height + 40; y += step) {
      // Inverse map screen Y to scroll track space
      double trackY;
      if (y < focusY) {
        // Horizon perspective zone
        final factor = (focusY - y) / (focusY - horizonY);
        trackY = effectiveScrollOffset + focusY - factor * (focusY < 50 ? 120 : 350);
      } else {
        trackY = effectiveScrollOffset + y;
      }

      // Winding curve formula
      final waveIndex = trackY / itemSpacing;
      final x = centerX + math.sin(waveIndex * math.pi) * amplitude;

      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw track and glow
    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, trackPaint);

    // Draw active milestone node beacons on the track
    final nodePaint = Paint()..style = PaintingStyle.fill;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (int i = 0; i < totalCount; i++) {
      final isLastNode = (i == totalCount - 1);
      final itemNaturalY = i * itemSpacing;
      final diff = itemNaturalY - scrollOffset;

      double visualY;
      double scale = 1.0;
      double opacity = 1.0;

      if (diff < 0) {
        if (isLastNode) {
          // Final node beacon stays locked at focus center on screen
          visualY = focusY;
          scale = 1.0;
          opacity = 1.0;
        } else {
          // Horizon receding
          final factor = (-diff / (focusY < 50 ? 240.0 : 380.0)).clamp(0.0, 1.0);
          scale = (1.0 - 0.75 * factor).clamp(0.2, 1.0);
          opacity = math.pow(1.0 - factor, 1.5).toDouble().clamp(0.0, 1.0);
          visualY = focusY - (focusY - horizonY) * (1.0 - math.exp(-2.5 * factor));
        }
      } else {
        // Approaching from bottom
        final factor = (diff / (focusY < 50 ? 300.0 : 450.0)).clamp(0.0, 1.0);
        scale = (1.0 - 0.4 * factor).clamp(0.5, 1.0);
        opacity = (1.0 - 0.7 * factor).clamp(0.0, 1.0);
        visualY = focusY + diff;
      }

      if (visualY < horizonY - 20 || visualY > size.height + 40 || opacity < 0.05) {
        continue;
      }

      final waveVal = (itemNaturalY / itemSpacing);
      final visualX = centerX + math.sin(waveVal * math.pi) * amplitude;

      // Outer glowing ring
      ringPaint.color = accentColor.withValues(alpha: opacity * 0.7);
      canvas.drawCircle(Offset(visualX, visualY), 10.0 * scale, ringPaint);

      // Inner solid beacon dot
      final isHighlighted = (diff.abs() < (focusY < 50 ? 35 : 50)) || (isLastNode && diff < 0);
      nodePaint.color = isHighlighted
          ? accentColor.withValues(alpha: opacity)
          : (isDark ? Colors.white70 : Colors.black87).withValues(alpha: opacity * 0.8);
      canvas.drawCircle(Offset(visualX, visualY), 4.5 * scale, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant TimelineTrackPainter oldDelegate) {
    return oldDelegate.scrollOffset != scrollOffset ||
        oldDelegate.amplitude != amplitude ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDark != isDark ||
        oldDelegate.totalCount != totalCount ||
        oldDelegate.focusY != focusY ||
        oldDelegate.horizonY != horizonY;
  }
}
