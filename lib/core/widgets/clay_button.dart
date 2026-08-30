import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ClayButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final double borderRadius;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;

  const ClayButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = AppColors.primaryContainer,
    this.borderRadius = 24.0, // rounded-xl
    this.width = double.infinity,
    this.height = 64.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
  });

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        padding: widget.padding,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: _isPressed
              ? []
              : [
                  // Outer Shadow
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(0, 12),
                    blurRadius: 24,
                  ),
                  // Inner Highlight (simulated via gradient/border in Flutter, or simple inset shadows)
                  // For a true inner shadow we use a trick with gradients or multiple containers
                  const BoxShadow(
                    color: Color(0x66FFFFFF), // rgba(255, 255, 255, 0.4)
                    offset: Offset(0, -4),
                    blurRadius: 8,
                    blurStyle: BlurStyle.inner,
                  ),
                  // Inner Shadow
                  const BoxShadow(
                    color: Color(0x33000000), // rgba(0, 0, 0, 0.2)
                    offset: Offset(0, 4),
                    blurRadius: 12,
                    blurStyle: BlurStyle.inner,
                  ),
                ],
        ),
        child: Center(
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
