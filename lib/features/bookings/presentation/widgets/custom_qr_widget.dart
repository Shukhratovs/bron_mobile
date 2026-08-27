import 'package:flutter/material.dart';

class CustomQrWidget extends StatelessWidget {
  final String data;
  final double size;
  final Color color;

  const CustomQrWidget({
    super.key,
    required this.data,
    this.size = 180,
    this.color = const Color(0xFF181A20),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _QrPainter(color: color),
    );
  }
}

class _QrPainter extends CustomPainter {
  final Color color;

  _QrPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final cell = size.width / 21; // 21x21 QR matrix

    // Pre-calculated classic QR Matrix with 3 eye finders
    const matrix = [
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [1,0,0,0,0,0,1,0,0,1,1,0,0,0,1,0,0,0,0,0,1],
      [1,0,1,1,1,0,1,0,1,0,0,1,0,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,0,1,0,1,1,0,1,0,1,1,1,0,1],
      [1,0,1,1,1,0,1,0,1,1,0,0,0,0,1,0,1,1,1,0,1],
      [1,0,0,0,0,0,1,0,0,0,1,0,1,0,1,0,0,0,0,0,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,1,1,1,1,1,1,1],
      [0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,0],
      [1,1,0,1,0,1,1,1,0,0,1,0,1,1,1,0,1,0,1,1,0],
      [0,1,0,0,1,0,0,0,1,1,0,1,0,0,0,1,0,1,0,1,1],
      [1,0,1,1,0,1,1,0,1,0,1,0,1,1,0,0,1,0,0,1,0],
      [0,1,0,0,1,0,0,1,0,1,0,1,0,1,1,0,1,1,0,0,1],
      [1,0,1,1,0,1,1,0,1,0,0,0,1,0,0,1,0,0,1,1,0],
      [0,0,0,0,0,0,0,0,1,1,0,1,0,1,0,1,0,1,0,1,1],
      [1,1,1,1,1,1,1,0,1,0,1,0,1,0,0,0,1,0,1,0,0],
      [1,0,0,0,0,0,1,0,0,1,0,1,1,1,1,0,0,1,0,1,1],
      [1,0,1,1,1,0,1,0,1,0,1,0,0,0,1,1,0,0,1,0,0],
      [1,0,1,1,1,0,1,0,0,1,1,0,1,0,0,1,1,0,0,1,1],
      [1,0,1,1,1,0,1,0,1,1,0,1,0,1,1,0,1,1,0,0,1],
      [1,0,0,0,0,0,1,0,0,0,1,0,1,0,0,1,0,1,1,0,0],
      [1,1,1,1,1,1,1,0,1,1,0,1,0,1,1,0,1,0,1,1,1],
    ];

    for (int r = 0; r < 21; r++) {
      for (int c = 0; c < 21; c++) {
        if (matrix[r][c] == 1) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromLTWH(c * cell, r * cell, cell - 0.5, cell - 0.5),
              const Radius.circular(1.5),
            ),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrPainter oldDelegate) => oldDelegate.color != color;
}
