import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/OTP/otp_views.dart';
import 'package:motor_secure/screens/login/login_view.dart';
import 'package:motor_secure/screens/register/register_contract.dart';
import 'package:motor_secure/screens/register/register_presenter.dart';
import 'package:motor_secure/widgets/custom_button.dart';
import 'package:motor_secure/widgets/custom_text_field.dart';
import 'package:motor_secure/widgets/util_widgets.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const String routeName = 'register_screen';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    implements RegisterViewContract {
  RegisterPresenter? _registerPresenter;

  final emailController = TextEditingController();
  String? error;

  @override
  void initState() {
    _registerPresenter = RegisterPresenter(this);
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
                fit: BoxFit.cover,
              ),
              const Gap(20),
              Text(
                'REGISTER',
                style: AppTextStyles.profileTitle,
              ),
              const Gap(50),
              ProfileInput(
                controller: emailController,
                icon: FontAwesomeIcons.user,
                hintText: 'Your Email',
                errorText: error,
              ),
              const Gap(35),
              AuthButton(
                buttonName: 'SIGN UP',
                onPressed: () async {
                  await _registerPresenter!.register(emailController.text);
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
                      'Already have an account?',
                      style: AppTextStyles.profileIntroText,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).pushNamed(LoginScreen.routeName);
                      },
                      child: Text(
                        'SIGN IN',
                        style: AppTextStyles.profileTextButton,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onEmailAlreadyInUse() {
    setState(() {
      error = "This email is already registered";
    });
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onRegisterFailed() {
    UtilWidgets.createDismissibleDialog(
        context,
        UtilWidgets.NOTIFICATION,
        "An error occurred while registering your account."
        " Please try again later.",
        () {
          Navigator.of(context, rootNavigator: true).pop();
        }
    );
  }

  @override
  void onRegisterSucceeded() {
    Navigator.of(context).pushNamed(OTPScreen.routeName);
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }
}
