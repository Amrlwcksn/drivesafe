import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

void main() {
  print('Generating "Friendly & Modern" icon...');
  const size = 1024;
  final image = img.Image(width: size, height: size);

  // --- 1. Background (Vibrant Gradient) ---
  // Cyan (Top-Left) to Deep Blue (Bottom-Right) -> Friendly Tech vibe
  final c1 = img.ColorRgb8(0, 198, 255); // Bright Cyan
  final c2 = img.ColorRgb8(0, 114, 255); // Rich Blue

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final t = (x + y) / (2.0 * size);
      final r = (c1.r + (c2.r - c1.r) * t).toInt();
      final g = (c1.g + (c2.g - c1.g) * t).toInt();
      final b = (c1.b + (c2.b - c1.b) * t).toInt();
      image.setPixel(x, y, img.ColorRgb8(r, g, b));
    }
  }

  // Helper to draw a filled circle with alpha blending (manual simplified)
  void drawCircle(int cx, int cy, int radius, img.Color color) {
    img.fillCircle(image, x: cx, y: cy, radius: radius, color: color);
  }

  // Draw Wrench at 45 Degrees (Bottom-Left to Top-Right)
  // We simulate rotation by drawing circles along the path and manual shaping

  final wrenchColor = img.ColorRgb8(255, 255, 255); // White
  final shadowColor = img.ColorRgb8(0, 0, 0); // Black for shadow (simulated)

  void drawWrench(int offsetX, int offsetY, img.Color color) {
    // Center point
    double cx = 512.0 + offsetX;
    double cy = 512.0 + offsetY;

    // Wrench Main Axis (Diagonal \ )
    // Head (Open) at Top-Left, Box (Ring) at Bottom-Right
    // Actually user wants "Modern", "Friendly".
    // Let's do diagonal / (Bottom-Left to Top-Right)

    // 1. Handle (Thick Line)
    // We draw multiple circles to simulate a thick rounded line or simple geometry
    // Start: (300, 724) End: (724, 300) roughly

    for (int i = 0; i <= 400; i += 1) {
      // Interpolate positions
      double t = i / 400.0;
      int x = (350 + (674 - 350) * t).toInt() + offsetX;
      int y = (674 + (350 - 674) * t).toInt() + offsetY;
      // Thickness radius = 60
      drawCircle(x, y, 60, color);
    }

    // 2. Open Head (Top-Right)
    // Draw large circle
    int headX = 700 + offsetX;
    int headY = 324 + offsetY;
    drawCircle(headX, headY, 140, color);

    // 3. Box End (Bottom-Left)
    int boxX = 324 + offsetX;
    int boxY = 700 + offsetY;
    drawCircle(boxX, boxY, 110, color);
  }

  // --- 2. Drop Shadow (Soft) ---
  // Simulate shadow by drawing dark offset
  // Since we don't have alpha blend, we'll just draw a dark solid shape behind
  // It won't be soft/blurred, but it gives depth (Material style)
  drawWrench(40, 40, img.ColorRgb8(0, 60, 150)); // Dark Blue Shadow

  // --- 3. Main Wrench (White) ---
  drawWrench(0, 0, wrenchColor);

  // --- 4. Cutouts (The "Holes" - Color of Background) ---
  // We need to sample background color at the specific points to "erase"
  // Or just pick a solid color that matches the gradient at that point roughly

  final cutoutColorHead = img.ColorRgb8(0, 150, 255); // Mid-Cyan
  final cutoutColorBox = img.ColorRgb8(0, 80, 200); // Mid-Blue

  // Open Head Cutout (Top-Right)
  // "U" shape axis is 45deg
  int hx = 700;
  int hy = 324;
  // Center hole
  drawCircle(hx, hy, 70, cutoutColorHead);
  // Slot opening (towards Top-Right corner)
  // Draw line of circles clearing it out
  for (int i = 0; i < 150; i += 5) {
    drawCircle(hx + i, hy - i, 70, cutoutColorHead);
  }

  // Box End Cutout (Bottom-Left)
  drawCircle(324, 700, 50, cutoutColorBox);

  // Save to file
  final file = File('assets/icon/app_icon.png');
  file.writeAsBytesSync(img.encodePng(image));
  print('Friendly Modern Icon created at ${file.path}');
}
