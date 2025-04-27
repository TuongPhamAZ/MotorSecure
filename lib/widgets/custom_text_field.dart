import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';

class ProfileInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool? obscureText;
  final String? errorText;
  final IconData? icon;
  const ProfileInput({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.errorText,
    this.icon,
  });

  @override
  State<ProfileInput> createState() => _ProfileInputState();
}

class _ProfileInputState extends State<ProfileInput> {
  late bool isObscure;
  @override
  void initState() {
    super.initState();
    isObscure = widget.obscureText!;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      cursorColor: AppPalette.primaryGreen,
      style: AppTextStyles.robo16Medi,
      obscureText: isObscure,
      decoration: InputDecoration(
        errorText: widget.errorText,
        errorStyle: AppTextStyles.profileHintText.copyWith(
          color: Colors.red,
        ),
        hintText: widget.hintText,
        hintStyle: AppTextStyles.profileHintText,
        prefixIcon: Icon(
          widget.icon,
          size: 25,
          color: widget.errorText != null ? Colors.red : Colors.grey,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
          ),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: AppPalette.primaryGreen,
          ),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
        ),
        suffixIcon: widget.obscureText!
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscure = !isObscure;
                  });
                },
                icon: Icon(
                  isObscure ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              )
            : null,
      ),
    );
  }
}
