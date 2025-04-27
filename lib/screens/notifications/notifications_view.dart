import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/data/models/notification_model.dart';
import 'package:motor_secure/screens/notifications/notifications_presenter.dart';
import 'package:motor_secure/screens/notifications/notifications_view_contract.dart';
import 'package:motor_secure/widgets/bottom_bar_custom.dart';
import 'package:motor_secure/widgets/notification_list_item.dart';
import 'package:motor_secure/widgets/util_widgets.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});
  static const String routeName = 'notifications_view';

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView>
    implements NotificationsViewContract {
  late NotificationsPresenter _presenter;
  bool _isLoading = true;
  String _errorMessage = '';
  List<NotificationModel> _notifications = [];
  int? _selectedItemIndex;

  @override
  void initState() {
    _presenter = NotificationsPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter.loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            FontAwesomeIcons.solidBell,
            color: AppPalette.primaryColor,
            size: 35,
          ),
        ),
        shape: Border(
          bottom: BorderSide(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'NOTIFICATIONS',
          style: AppTextStyles.profileTitle.copyWith(fontSize: 32),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              loadData();
            },
            icon: Icon(
              FontAwesomeIcons.rotateLeft,
              color: AppPalette.primaryColor,
            ),
          ),
        ],
      ),
      body: _isLoading
          ? UtilWidgets.getLoadingWidget()
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Text(_errorMessage),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Text(
                        'No notifications yet!',
                        style: AppTextStyles.heading,
                      ),
                    )
                  : ListView.builder(
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) => GestureDetector(
                        onLongPress: () {
                          setState(() {
                            _selectedItemIndex = index;
                          });
                        },
                        child: NotificationListItem(
                          notification: _notifications[index],
                          onDelete: _selectedItemIndex == index
                              ? () => _showDeleteConfirmDialog(index)
                              : null,
                        ),
                      ),
                    ),
      bottomNavigationBar: BottomBarCustom(currentIndex: 0),
    );
  }

  @override
  void onLoadNotificationsSuccess(List<NotificationModel> notifications) {
    setState(() {
      _notifications = notifications;
      _isLoading = false;
    });
  }

  @override
  void onLoadNotificationsFailed(String errorMessage) {
    setState(() {
      _errorMessage = errorMessage;
      _isLoading = false;
    });
  }

  @override
  void onPopContext() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  @override
  void onWaitingProgressBar() {
    UtilWidgets.createLoadingWidget(context);
  }

  void _showDeleteConfirmDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Xác nhận'),
        content: Text('Bạn có chắc muốn xóa thông báo này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              onWaitingProgressBar();
              final result = await _presenter.deleteNotification(
                _notifications[index].id,
              );
              onPopContext(); // Đóng dialog loading

              if (result) {
                setState(() {
                  _selectedItemIndex = null;
                  _notifications.removeAt(index);
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đã xóa thông báo thành công')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Không thể xóa thông báo. Vui lòng thử lại sau.')),
                );
              }
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
