import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

class NetworkBanner extends StatelessWidget {
  const NetworkBanner({super.key, this.expanded = false});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(expanded ? AppSpacing.xl : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FIELD OPERATIONS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF9FBAC9),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.8,
              ),
            ),
            if (expanded) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(
                'GIS Contractor\nworkspace.',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontSize: 42,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'SLT service operations',
                style: TextStyle(color: Color(0xFFB8CEDB), fontSize: 16),
              ),
              const SizedBox(height: AppSpacing.section),
            ],
            ExcludeSemantics(
              child: SizedBox(
                width: double.infinity,
                height: expanded ? 210 : 106,
                child: const CustomPaint(painter: _NetworkPainter()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// A simple telecom line drawing keeps the artwork crisp at any screen size.
class _NetworkPainter extends CustomPainter {
  const _NetworkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 400, size.height / 160);
    final line = Paint()
      ..color = const Color(0xFF688C9F)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final accent = Paint()
      ..color = const Color(0xFF52C6BE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(8, 149), const Offset(392, 149), line);
    for (final pole in [
      const Offset(58, 48),
      const Offset(200, 14),
      const Offset(342, 48),
    ]) {
      canvas.drawLine(pole, Offset(pole.dx, 149), line);
      canvas.drawLine(
        Offset(pole.dx - 22, pole.dy + 8),
        Offset(pole.dx + 22, pole.dy + 8),
        line,
      );
      for (final dx in [-16.0, 16.0]) {
        canvas.drawLine(
          Offset(pole.dx + dx, pole.dy + 3),
          Offset(pole.dx + dx, pole.dy + 14),
          accent,
        );
      }
    }

    for (final dx in [-16.0, 16.0]) {
      final cable = Path()
        ..moveTo(58 + dx, 53)
        ..quadraticBezierTo(129 + dx, 90, 200 + dx, 19)
        ..quadraticBezierTo(271 + dx, 90, 342 + dx, 53);
      canvas.drawPath(cable, line);
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(184, 82, 32, 43),
        const Radius.circular(3),
      ),
      Paint()..color = AppColors.navy,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(184, 82, 32, 43),
        const Radius.circular(3),
      ),
      line,
    );
    canvas.drawCircle(
      const Offset(194, 94),
      2.5,
      Paint()..color = const Color(0xFF52C6BE),
    );
    canvas.drawLine(const Offset(192, 105), const Offset(208, 105), line);
    canvas.drawLine(const Offset(192, 111), const Offset(208, 111), line);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _NetworkPainter oldDelegate) => false;
}
