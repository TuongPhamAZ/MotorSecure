import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/forgot_password/forgot_password.dart';
import 'package:motor_secure/screens/home/home_view.dart';
import 'package:motor_secure/screens/login/login_contract.dart';
import 'package:motor_secure/screens/login/login_presenter.dart';
import 'package:motor_secure/screens/register/register_view.dart';
import 'package:motor_secure/widgets/custom_button.dart';
import 'package:motor_secure/widgets/custom_text_field.dart';
import 'package:motor_secure/widgets/util_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const String routeName = 'login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginViewContract {
  LoginPresenter? _loginPresenter;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  BuildContext? progressbarContext;
  String? error;

  @override
  void initState() {
    _loginPresenter = LoginPresenter(this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: size.width,
          padding: const EdgeInsets.all(50),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(50),
              Image.asset(
                Art.logoNobg,
                width: 200,
                height: 200,
              ),
              const Gap(20),
              Text(
                'LOGIN',
                style: AppTextStyles.profileTitle,
              ),
              const Gap(36),
              ProfileInput(
                controller: emailController,
                icon: FontAwesomeIcons.user,
                hintText: 'Username',
                errorText: error,
              ),
              const Gap(20),
              ProfileInput(
                controller: passwordController,
                icon: Icons.lock_outline_rounded,
                hintText: 'Password',
                obscureText: true,
                errorText: error,
              ),
              const Gap(35),
              AuthButton(
                buttonName: 'SIGN IN',
                onPressed: () async {
                  await _loginPresenter!.login(emailController.text.trim(),
                      passwordController.text.trim());
                },
              ),
              const Gap(20),
              Container(
                width: 280,
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Don\'t have an account? ',
                      style: AppTextStyles.profileIntroText,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(RegisterScreen.routeName);
                      },
                      child: Text(
                        'Register',
                        style: AppTextStyles.profileTextButton,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(5),
              InkWell(
                onTap: () {
                  Navigator.of(context)
                      .pushNamed(ForgotPasswordScreen.routeName);
                },
                child: Container(
                  width: 280,
                  alignment: Alignment.center,
                  child: Text(
                    'Forgot Password',
                    style: AppTextStyles.profileTextButton
                        .copyWith(color: AppPalette.primaryGreen),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onLoginFailed() {
    setState(() {
      error = "Email or password is invalid";
    });
  }

  @override
  void onLoginSucceeded() {
    Navigator.of(context).pushNamed(HomeView.routeName);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onError(String message) {
    UtilWidgets.createSnackBar(context, message);
    setState(() {
      error = "";
    });
  }
}
