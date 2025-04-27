import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';

abstract class UtilWidgets {
  // const title
  static const NOTIFICATION = "Notification";
  static const WARNING = "Warning";

  static void createLoadingWidget(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });
  }

  static void createDialog(BuildContext context, String title, String content,
      VoidCallback onClick) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: onClick,
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void createDismissibleDialog(BuildContext context, String title,
      String content, VoidCallback onClick) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: onClick,
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  static void createSnackBar(BuildContext context, String content) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppPalette.primaryColor,
        content: Text(
          content,
          style: AppTextStyles.robo17.copyWith(color: Colors.white),
        ),
      ),
    );
  }

  static Widget getLoadingWidget() {
    return const Center(child: CircularProgressIndicator());
  }

  static Widget getLoadingWidgetWithContainer(
      {required double width, required double height}) {
    return SizedBox(width: width, height: height, child: getLoadingWidget());
  }

  static Widget getCenterTextWithContainer({
    required double width,
    required double height,
    String? text,
    Color? color,
    double? fontSize,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: Center(
        child: Text(text ?? "",
            style: TextStyle(
              color: color ?? AppPalette.primaryColor,
              fontSize: fontSize ?? 16,
            )),
      ),
    );
  }

  static Widget? createSnapshotResultWidget(context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError) {
      return Center(child: Text('Error: ${snapshot.error}'));
    }

    return null;
  }
}
