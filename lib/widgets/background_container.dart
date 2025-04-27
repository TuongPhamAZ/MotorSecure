import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/app_palette.dart';

class BackgroundContainer extends StatelessWidget {
  final Widget child;
  final Alignment? alignment;
  final double horizontalPadding;
  final double verticalPadding;
  const BackgroundContainer(
      {super.key,
      required this.child,
      this.alignment,
      this.horizontalPadding = 12,
      this.verticalPadding = 8});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppPalette.containerBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 4),
            blurRadius: 4,
          ),
        ],
      ),
      child: child,
    );
  }
}
