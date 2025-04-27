import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/home/home_presenter.dart';
import 'package:motor_secure/screens/home/home_view_contract.dart';
import 'package:motor_secure/widgets/bottom_bar_custom.dart';
import 'package:motor_secure/widgets/util_widgets.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});
  static const String routeName = 'home_view';

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> implements HomeViewContract {
  late HomePresenter _presenter;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            FontAwesomeIcons.earthAmericas,
            color: AppPalette.primaryColor,
            size: 35,
          ),
        ),
        shape: Border(
          bottom: BorderSide(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'GPS TRACKING',
          style: AppTextStyles.profileTitle,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              FontAwesomeIcons.rotateLeft,
              color: AppPalette.primaryColor,
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_isLoading)
                const CircularProgressIndicator()
              else if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Lỗi: $_errorMessage',
                    style: const TextStyle(color: Colors.red, fontSize: 18),
                  ),
                )
              else
                Column(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: Colors.red,
                      size: 80,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mô phỏng thiết bị phát hiện bất thường',
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Nhấn nút bên dưới để gửi thông báo khẩn cấp đến thiết bị',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () {
                          _presenter.sendEmergencyNotification();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'GỬI CẢNH BÁO KHẨN CẤP',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomBarCustom(currentIndex: 1),
    );
  }

  @override
  void onLoadUserDataSucceeded(int tokenCount) {
    setState(() {
      _isLoading = false;
      _errorMessage = '';
    });
  }

  @override
  void onLoadUserDataFailed(String message) {
    setState(() {
      _isLoading = false;
      _errorMessage = message;
    });
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onSendNotificationSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã gửi thông báo khẩn cấp thành công!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  void onSendNotificationFailed(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Gửi thông báo thất bại: $message'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
