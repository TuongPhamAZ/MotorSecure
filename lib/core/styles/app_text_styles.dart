import 'package:flutter/material.dart';
import '../constants/app_palette.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyles {
  AppTextStyles(this.context);
  final BuildContext context;

  static TextStyle profileTitle = GoogleFonts.roboto(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    color: const Color.fromARGB(255, 6, 119, 45),
    shadows: [
      Shadow(
        color: Colors.black.withOpacity(0.25),
        offset: const Offset(0, 4),
        blurRadius: 4,
      ),
    ],
    letterSpacing: 1.1,
  );

  static TextStyle noInternetDes = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: Colors.black,
  );

  static TextStyle footerText = GoogleFonts.roboto(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static TextStyle profileHintText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.grey,
  );

  static TextStyle profileIntroText = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static TextStyle robo16Medi = GoogleFonts.roboto(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle robo17 = GoogleFonts.roboto(
    fontSize: 17,
    color: Colors.black,
  );

  static TextStyle profileButtonText = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static TextStyle profileTextButton = GoogleFonts.roboto(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    color: const Color.fromARGB(255, 55, 168, 58),
  );

  static TextStyle otpIntroText = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w400,
    color: AppPalette.main1,
  );

  static TextStyle otpEmailText = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static TextStyle noInternetTitle = GoogleFonts.roboto(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  static TextStyle buttonText = GoogleFonts.roboto(
    fontSize: 21,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static TextStyle profileLable = GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    color: const Color.fromARGB(255, 34, 122, 37),
  );

  static TextStyle profileName = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppPalette.primaryColor,
  );

  static TextStyle heading = GoogleFonts.roboto(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppPalette.textPrimary,
  );
}
