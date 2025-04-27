import 'package:flutter/material.dart';
import 'package:motor_secure/screens/OTP/otp_views.dart';
import 'package:motor_secure/screens/edit_profile/edit_profile.dart';
import 'package:motor_secure/screens/forgot_password/forgot_password.dart';
import 'package:motor_secure/screens/home/home_view.dart';
import 'package:motor_secure/screens/login/login_view.dart';
import 'package:motor_secure/screens/no_internet/no_internet.dart';
import 'package:motor_secure/screens/notifications/notifications_view.dart';
import 'package:motor_secure/screens/profile/profile_view.dart';
import 'package:motor_secure/screens/register/register_view.dart';
import 'package:motor_secure/screens/user_information/user_information_view.dart';
import 'screens/splash/splash_view.dart';

final Map<String, WidgetBuilder> appRoutes = {
  SplashView.routeName: (context) => const SplashView(),
  NoNetworkScreen.routeName: (context) => const NoNetworkScreen(),
  RegisterScreen.routeName: (context) => const RegisterScreen(),
  LoginScreen.routeName: (context) => const LoginScreen(),
  OTPScreen.routeName: (context) => const OTPScreen(),
  UserInformation.routeName: (context) => const UserInformation(),
  HomeView.routeName: (context) => const HomeView(),
  ForgotPasswordScreen.routeName: (context) => const ForgotPasswordScreen(),
  NotificationsView.routeName: (context) => const NotificationsView(),
  ProfileView.routeName: (context) => const ProfileView(),
  EditProfileScreen.routeName: (context) => const EditProfileScreen(),
};
