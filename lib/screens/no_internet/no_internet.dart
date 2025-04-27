import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/widgets/custom_button.dart';

class NoNetworkScreen extends StatefulWidget {
  const NoNetworkScreen({super.key});
  static const String routeName = 'no_network_screen';

  @override
  State<NoNetworkScreen> createState() => _NoNetworkScreenState();
}

class _NoNetworkScreenState extends State<NoNetworkScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Art.noInternet,
              width: 325,
              height: 260,
            ),
            Text(
              'Not Connected',
              style: AppTextStyles.noInternetTitle,
            ),
            const SizedBox(height: 12),
            Text(
              'Ups. You are not connected to internet\nTry again',
              textAlign: TextAlign.center,
              style: AppTextStyles.noInternetDes,
            ),
            const SizedBox(height: 30),
            AuthButton(
              buttonName: 'Try Again',
              onPressed: () {},
            )
          ],
        ),
      ),
    );
  }
}
