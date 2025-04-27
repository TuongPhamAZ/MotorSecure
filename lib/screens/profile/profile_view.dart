import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/edit_profile/edit_profile.dart';
import 'package:motor_secure/screens/login/login_view.dart';
import 'package:motor_secure/screens/profile/profile_view_contract.dart';
import 'package:motor_secure/screens/profile/profile_view_presenter.dart';
import 'package:motor_secure/widgets/bottom_bar_custom.dart';
import 'package:motor_secure/widgets/custom_button.dart';
import 'package:motor_secure/widgets/util_widgets.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});
  static const String routeName = 'profile_view';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView>
    implements ProfileScreenContract {
  ProfileScreenPresenter? _presenter;
  String name = "";
  String dob = "";
  String address = "";
  String phone = "";
  List<String> vehicle = [];
  bool _isLoading = true;

  @override
  void initState() {
    _presenter = ProfileScreenPresenter(this);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  Future<void> loadData() async {
    await _presenter?.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: EdgeInsets.only(left: 10),
          child: Icon(
            FontAwesomeIcons.gears,
            color: AppPalette.primaryColor,
            size: 40,
          ),
        ),
        shape: Border(
          bottom: BorderSide(),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'PROFILE',
          style: AppTextStyles.profileTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: _isLoading
            ? UtilWidgets.getLoadingWidget()
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(20),
                    Text(
                      'Your Vehicles:',
                      style: AppTextStyles.profileLable,
                    ),
                    const Gap(10),
                    vehicle.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(left: 25),
                            child: Text(
                              'You have no vehicle!!!',
                              style: AppTextStyles.profileTextButton.copyWith(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : Column(
                            children: List.generate(
                              vehicle.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 5),
                                child: Row(
                                  children: [
                                    const Gap(25),
                                    Text(
                                      'Vehicle ${index + 1}: ',
                                      style: AppTextStyles.profileTextButton
                                          .copyWith(
                                              color: const Color.fromARGB(
                                                  255, 2, 70, 4)),
                                    ),
                                    Text(vehicle[index],
                                        style: AppTextStyles.profileTextButton),
                                  ],
                                ),
                              ),
                            ),
                          ),
                    const Gap(8),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: AuthButton(
                        height: 50,
                        buttonName: 'Add Vehicle',
                        onPressed: () {
                          _showAddVehicleDialog(context);
                        },
                      ),
                    ),
                    const Gap(25),
                    Text(
                      'Owner:',
                      style: AppTextStyles.profileLable,
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            FontAwesomeIcons.user,
                            color: Color.fromARGB(255, 2, 70, 4),
                            size: 25,
                          ),
                        ),
                        Text(
                          'Name: ',
                          style: AppTextStyles.profileTextButton.copyWith(
                              color: const Color.fromARGB(255, 2, 70, 4)),
                        ),
                        Text(name, style: AppTextStyles.profileTextButton),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            FontAwesomeIcons.calendar,
                            color: Color.fromARGB(255, 2, 70, 4),
                            size: 25,
                          ),
                        ),
                        Text(
                          'DOB: ',
                          style: AppTextStyles.profileTextButton.copyWith(
                              color: const Color.fromARGB(255, 2, 70, 4)),
                        ),
                        Text(dob, style: AppTextStyles.profileTextButton),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            FontAwesomeIcons.locationDot,
                            color: Color.fromARGB(255, 2, 70, 4),
                            size: 25,
                          ),
                        ),
                        Text(
                          'Address: ',
                          style: AppTextStyles.profileTextButton.copyWith(
                              color: const Color.fromARGB(255, 2, 70, 4)),
                        ),
                        Text(address, style: AppTextStyles.profileTextButton),
                      ],
                    ),
                    const Gap(10),
                    Row(
                      children: [
                        Container(
                          width: 50,
                          alignment: Alignment.center,
                          child: const Icon(
                            FontAwesomeIcons.phone,
                            color: Color.fromARGB(255, 2, 70, 4),
                            size: 25,
                          ),
                        ),
                        Text(
                          'Phone: ',
                          style: AppTextStyles.profileTextButton.copyWith(
                              color: const Color.fromARGB(255, 2, 70, 4)),
                        ),
                        Text(phone, style: AppTextStyles.profileTextButton),
                      ],
                    ),
                    const Gap(10),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: AuthButton(
                        height: 50,
                        buttonName: 'Edit Information',
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(EditProfileScreen.routeName);
                        },
                      ),
                    ),
                    const Gap(15),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      child: AuthButton(
                        height: 50,
                        color: const Color.fromARGB(255, 120, 120, 13),
                        buttonName: 'Sign Out',
                        onPressed: () async {
                          showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'Are you sure you want to sign out?'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: Text(
                                      'Cancel',
                                      style: AppTextStyles.profileIntroText,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      _presenter!.signOut();
                                    },
                                    child: Text(
                                      'Confirm',
                                      style: AppTextStyles.profileIntroText
                                          .copyWith(
                                        color: AppPalette.main1,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const Gap(25),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: BottomBarCustom(currentIndex: 2),
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final TextEditingController vehicleIdController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Vehicle', style: AppTextStyles.profileLable),
          content: TextField(
            controller: vehicleIdController,
            decoration: InputDecoration(
              hintText: 'Enter vehicle ID',
              hintStyle: AppTextStyles.profileHintText,
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: AppTextStyles.profileIntroText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _presenter!.addVehicle(vehicleIdController.text.trim());
              },
              child: Text(
                'Add',
                style: AppTextStyles.profileIntroText.copyWith(
                  color: AppPalette.main1,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      name = _presenter!.user!.name;
      dob = DateFormat('dd/MM/yyyy').format(_presenter!.user!.dob);
      address = _presenter!.user!.address;
      phone = _presenter!.user!.phone;
      vehicle = _presenter!.user!.vehicleId;
      _isLoading = false;
    });
  }

  @override
  void onSignOut() {
    Navigator.of(context).pushNamed(LoginScreen.routeName);
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
  void onAddVehicleSucceeded() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thêm phương tiện thành công'),
        backgroundColor: Colors.green,
      ),
    );
    // Cập nhật lại dữ liệu
    setState(() {
      _isLoading = true;
    });
    loadData();
  }

  @override
  void onAddVehicleFailed(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
