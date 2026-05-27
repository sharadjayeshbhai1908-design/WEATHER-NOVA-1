import 'dart:math' as math;
import 'package:flutter/material.dart';

class AppLogo extends StatefulWidget {
  final double size;
  final bool animate;
  const AppLogo({super.key, this.size = 36, this.animate = true});

  @override
  State<AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<AppLogo> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    );
    if (widget.animate) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer soft glow aura
            Container(
              width: widget.size * 1.1,
              height: widget.size * 1.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyanAccent.withAlpha(25),
                    blurRadius: widget.size * 0.4,
                    spreadRadius: widget.size * 0.05,
                  ),
                  BoxShadow(
                    color: Colors.purpleAccent.withAlpha(15),
                    blurRadius: widget.size * 0.6,
                    spreadRadius: widget.size * 0.1,
                  ),
                ],
              ),
            ),
            // Custom drawn vector logo
            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: _LogoPainter(rotation: _controller.value * 2 * math.pi),
            ),
          ],
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double rotation;
  _LogoPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double cx = w / 2;
    final double cy = h / 2;
    final double radius = w * 0.42;

    // 1. Camera Scanning Brackets (4 Corners)
    final Paint bracketPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.06
      ..strokeCap = StrokeCap.round;

    final double len = w * 0.16;
    // Top-Left
    canvas.drawLine(Offset(cx - radius, cy - radius), Offset(cx - radius + len, cy - radius), bracketPaint);
    canvas.drawLine(Offset(cx - radius, cy - radius), Offset(cx - radius, cy - radius + len), bracketPaint);
    // Top-Right
    canvas.drawLine(Offset(cx + radius, cy - radius), Offset(cx + radius - len, cy - radius), bracketPaint);
    canvas.drawLine(Offset(cx + radius, cy - radius), Offset(cx + radius, cy - radius + len), bracketPaint);
    // Bottom-Left
    canvas.drawLine(Offset(cx - radius, cy + radius), Offset(cx - radius + len, cy + radius), bracketPaint);
    canvas.drawLine(Offset(cx - radius, cy + radius), Offset(cx - radius, cy + radius - len), bracketPaint);
    // Bottom-Right
    canvas.drawLine(Offset(cx + radius, cy + radius), Offset(cx + radius - len, cy + radius), bracketPaint);
    canvas.drawLine(Offset(cx + radius, cy + radius), Offset(cx + radius, cy + radius - len), bracketPaint);

    // 2. Inner Rotating Cybernetic Ring
    final Paint ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.035
      ..shader = SweepGradient(
        colors: [
          Colors.cyanAccent.withAlpha(200),
          Colors.purpleAccent.withAlpha(200),
          Colors.cyanAccent.withAlpha(200),
        ],
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius * 0.72));

    canvas.save();
    canvas.translate(cx, cy);
    canvas.rotate(rotation);
    canvas.translate(-cx, -cy);
    canvas.drawCircle(Offset(cx, cy), radius * 0.72, ringPaint);
    canvas.restore();

    // 3. Horizontal Purple Scanner Laser Line
    final Paint laserPaint = Paint()
      ..color = Colors.purpleAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.04
      ..strokeCap = StrokeCap.round;

    // Glowing laser path
    canvas.drawLine(
      Offset(cx - radius * 0.75, cy - h * 0.02),
      Offset(cx + radius * 0.75, cy - h * 0.02),
      laserPaint,
    );

    final Paint laserGlow = Paint()
      ..color = Colors.purpleAccent.withAlpha(100)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.09
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    canvas.drawLine(
      Offset(cx - radius * 0.75, cy - h * 0.02),
      Offset(cx + radius * 0.75, cy - h * 0.02),
      laserGlow,
    );

    // 4. Stylized Side-Profile Car Outline (No face elements)
    final Paint carPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path carPath = Path();
    // Rear bumper bottom
    carPath.moveTo(cx - w * 0.32, cy + h * 0.08);
    // Rear upward line
    carPath.lineTo(cx - w * 0.32, cy + h * 0.02);
    // Rear spoiler / trunk lid
    carPath.lineTo(cx - w * 0.24, cy - h * 0.02);
    // Rear windshield slope
    carPath.lineTo(cx - w * 0.10, cy - h * 0.11);
    // Roofline top
    carPath.lineTo(cx + w * 0.04, cy - h * 0.11);
    // Front windshield slope
    carPath.lineTo(cx + w * 0.16, cy - h * 0.01);
    // Front hood line
    carPath.lineTo(cx + w * 0.28, cy - h * 0.01);
    // Front nose / bumper
    carPath.lineTo(cx + w * 0.32, cy + h * 0.08);
    
    // Bottom chassis line and wheel wells
    // Front wheel arch
    carPath.lineTo(cx + w * 0.21, cy + h * 0.08);
    carPath.arcToPoint(
      Offset(cx + w * 0.09, cy + h * 0.08),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );
    // Underbody middle
    carPath.lineTo(cx - w * 0.09, cy + h * 0.08);
    // Rear wheel arch
    carPath.arcToPoint(
      Offset(cx - w * 0.21, cy + h * 0.08),
      radius: Radius.circular(w * 0.06),
      clockwise: false,
    );
    carPath.close();
    canvas.drawPath(carPath, carPaint);

    // 5. Wheels (Solid Cyan Tech Discs)
    final Paint wheelPaint = Paint()
      ..color = Colors.cyanAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + w * 0.15, cy + h * 0.08), w * 0.04, wheelPaint);
    canvas.drawCircle(Offset(cx - w * 0.15, cy + h * 0.08), w * 0.04, wheelPaint);
  }

  @override
  bool shouldRepaint(covariant _LogoPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}
