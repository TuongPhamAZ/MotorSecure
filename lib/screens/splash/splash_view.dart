import 'package:flutter/material.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/login/login_view.dart';
import 'package:motor_secure/screens/register/register_view.dart';
import 'package:motor_secure/screens/splash/splash_presenter.dart';
import 'package:motor_secure/screens/splash/splash_view_contract.dart';
import 'package:motor_secure/widgets/custom_button.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});
  static const String routeName = 'splash_screen';

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin
    implements SplashViewContract {
  AnimationController? _controller;
  Animation<double>? _animation;
  late SplashPresenter _presenter;

  @override
  void initState() {
    super.initState();

    _presenter = SplashPresenter(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(_controller!)
      ..addListener(() {
        setState(() {});
      });

    _controller!.forward();

    // Yêu cầu quyền thông báo và vị trí
    _presenter.requestNotificationPermissionOnce();
    _presenter.requestLocationPermissionOnce();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Container(
        height: size.height,
        width: size.width,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 26),
            // Logo
            Image.asset(
              Art.logoNobg,
              width: 280,
              fit: BoxFit.cover,
            ),

            //App name
            Image.asset(
              Art.appName,
              width: 280,
              fit: BoxFit.cover,
            ),

            Expanded(child: Container()),
            // Nút SIGN IN và SIGN UP
            Column(
              children: [
                AuthButton(
                  buttonName: 'SIGN IN',
                  onPressed: () {
                    Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },
                ),
                const SizedBox(height: 16),
                AuthButton(
                  buttonName: 'SIGN UP',
                  onPressed: () {
                    Navigator.of(context).pushNamed(RegisterScreen.routeName);
                  },
                  color: AppPalette.buttonBG2,
                  textColor: Colors.black,
                ),
              ],
            ),
            Expanded(child: Container()),

            Text(
              'Created by Nguyen Quang Huy',
              style: AppTextStyles.footerText,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void onNotificationPermissionGranted() {
    // Có thể hiển thị thông báo hoặc xử lý theo yêu cầu
    print('Quyền thông báo đã được cấp');
  }

  @override
  void onNotificationPermissionDenied() {
    // Có thể hiển thị dialog nhắc nhở người dùng bật quyền thông báo
    print('Quyền thông báo bị từ chối');
  }

  @override
  void onLocationPermissionGranted() {
    // Xử lý khi được cấp quyền vị trí
    print('Quyền vị trí đã được cấp');
  }

  @override
  void onLocationPermissionDenied() {
    // Xử lý khi bị từ chối quyền vị trí
    print('Quyền vị trí bị từ chối');
    // Có thể hiển thị dialog hướng dẫn người dùng bật quyền trong cài đặt
  }
}
