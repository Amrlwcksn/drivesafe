import 'dart:ui';
import 'package:flutter/material.dart';

class GlassContainer extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final double? blur; // Compatibility
  final double? opacity;
  final Color? color;
  final Color? borderColor;
  final BoxBorder? border;

  const GlassContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur,
    this.opacity,
    this.color,
    this.borderColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? 16.0;

    // Improved adaptive colors for "Crystal" style readability
    final defaultBgColor = isDark
        ? const Color(0xFF1C1C1E) // Dark iOS-like surface
        : Colors.white;

    // In Crystal style, we need higher default opacity for readability if no color is provided
    final defaultOpacity = isDark ? 0.85 : 0.95;

    final effectiveColor = color != null
        ? (opacity != null ? color!.withOpacity(opacity!) : color!)
        : defaultBgColor.withOpacity(opacity ?? defaultOpacity);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: padding ?? const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: effectiveColor,
            borderRadius: BorderRadius.circular(radius),
            border:
                border ??
                Border.all(
                  color:
                      borderColor ??
                      (isDark
                          ? Colors.white.withOpacity(0.15)
                          : Colors.black.withOpacity(0.1)),
                  width: 1.5,
                ),
          ),
          child: child,
        ),
      ),
    );
  }
}
