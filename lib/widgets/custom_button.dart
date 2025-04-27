import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';

class AuthButton extends StatelessWidget {
  final String buttonName;
  final VoidCallback onPressed;
  final Color color;
  final Color textColor;
  final double height;
  const AuthButton({
    super.key,
    required this.buttonName,
    required this.onPressed,
    this.color = AppPalette.primaryGreen,
    this.textColor = Colors.white,
    this.height = 60,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        fixedSize: Size(size.width * 0.75, height),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onPressed,
      child: Text(
        buttonName,
        style: AppTextStyles.buttonText.copyWith(
          color: textColor,
        ),
      ),
    );
  }
}
