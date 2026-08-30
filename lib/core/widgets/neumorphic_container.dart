import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class NeumorphicContainer extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double? width;
  final double? height;

  const NeumorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = 16.0, // rounded-lg
    this.padding = const EdgeInsets.all(16.0),
    this.margin = EdgeInsets.zero,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          // Light Shadow (Top-Left)
          const BoxShadow(
            color: AppColors.lightShadow,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          // Dark Shadow (Bottom-Right)
          const BoxShadow(
            color: AppColors.darkShadow,
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: child,
    );
  }
}
