import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:motor_secure/screens/no_internet/no_internet.dart';

class NetworkController extends GetxController {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _subscription;

  @override
  void onInit() {
    super.onInit();
    _checkInternet();
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _checkInternet();
    });
  }

  Future<void> _checkInternet() async {
    try {
      final result = await http
          .get(Uri.parse('https://www.google.com'))
          .timeout(const Duration(seconds: 5));
      if (result.statusCode == 200) {
        _goOnline();
      } else {
        _goOffline();
      }
    } catch (_) {
      _goOffline();
    }
  }

  void _goOffline() {
    if (Get.currentRoute != NoNetworkScreen.routeName) {
      Navigator.of(Get.context!).pushNamed(NoNetworkScreen.routeName);
    }
  }

  void _goOnline() {
    if (Get.currentRoute == NoNetworkScreen.routeName) {
      Get.back();
    }
  }
}
