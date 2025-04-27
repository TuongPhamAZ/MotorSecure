import 'package:flutter/material.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';

class AcceptButton extends StatelessWidget {
  final Function()? onPressed;
  final String name;
  const AcceptButton({super.key, this.name = 'Accept', this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size(180, 50),
        padding: const EdgeInsets.symmetric(vertical: 10),
        backgroundColor: Colors.green,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: name.isEmpty
          ? Text(
              'Cancel',
              style: AppTextStyles.profileTextButton.copyWith(color: Colors.white),
            )
          : Text(
              name,
              style: AppTextStyles.profileTextButton.copyWith(color: Colors.white),
            ),
    );
  }
}
