import 'package:flutter/material.dart';
import 'package:soundguide_app/constants/app_colors.dart';
import 'package:soundguide_app/constants/persona_config.dart';

class PersonaSlice extends StatefulWidget {
  final UserType userType;
  final PersonaInfo info;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isExpanded;

  const PersonaSlice({
    super.key,
    required this.userType,
    required this.info,
    required this.onTap,
    required this.isSelected,
    required this.isExpanded,
  });

  @override
  State<PersonaSlice> createState() => _PersonaSliceState();
}

class _PersonaSliceState extends State<PersonaSlice>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
  }

  @override
  void didUpdateWidget(PersonaSlice oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(gradient: widget.info.gradient),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.info.icon, size: 56, color: AppColors.white),
                const SizedBox(height: 16),
                Text(
                  widget.info.title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.info.subtitle,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
