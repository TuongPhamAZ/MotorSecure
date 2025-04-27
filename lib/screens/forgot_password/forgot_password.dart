import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/forgot_password/forgot_password_contract.dart';
import 'package:motor_secure/screens/forgot_password/forgot_password_presenter.dart';
import 'package:motor_secure/screens/login/login_view.dart';
import 'package:motor_secure/widgets/custom_button.dart';
import 'package:motor_secure/widgets/custom_text_field.dart';
import '../../widgets/util_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  static const String routeName = 'forgot_password';

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> implements ForgotPasswordContract {
  ForgotPasswordPresenter? _presenter;

  TextEditingController emailController = TextEditingController();
  String? error;

  @override
  void initState() {
    _presenter = ForgotPasswordPresenter(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(FontAwesomeIcons.arrowLeft),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        width: size.width,
        height: size.height,
        alignment: Alignment.center,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              Art.logoNobg,
              width: 150,
              height: 150,
            ),
            const Gap(20),
            Text(
              'Forgot Password',
              style: AppTextStyles.profileTitle,
            ),
            const Gap(50),
            ProfileInput(
              icon: FontAwesomeIcons.user,
              hintText: 'Your Email',
              controller: emailController,
              errorText: error,
            ),
            const Gap(35),
            AuthButton(
              buttonName: 'Confirm',
              onPressed: () {
                _presenter!.resetPassword(emailController.text);
              },
            ),
            const Gap(80),
          ],
        ),
      ),
    );
  }

  @override
  void onForgotPasswordError(String errorMessage) {
    setState(() {
      error = errorMessage;
    });
  }

  @override
  void onForgotPasswordSent() {
    UtilWidgets.createDialog(
        context,
        UtilWidgets.NOTIFICATION,
        "A password reset email has been sent to ${emailController.text.trim()}."
        " Please check your inbox and follow the instructions to reset your password.",
        () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context)
              .pushNamed(LoginScreen.routeName);
        }
    );
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }
}
