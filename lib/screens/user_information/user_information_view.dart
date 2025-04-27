import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/home/home_view.dart';
import 'package:motor_secure/screens/user_information/user_information_contract.dart';
import 'package:motor_secure/screens/user_information/user_information_presenter.dart';
import 'package:motor_secure/widgets/background_container.dart';
import 'package:motor_secure/widgets/custom_button.dart';
import '../../widgets/util_widgets.dart';

class UserInformation extends StatefulWidget {
  const UserInformation({super.key});
  static const String routeName = 'user_information';

  @override
  State<UserInformation> createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation>
    implements UserInformationContract {
  UserInformationPresenter? _presenter;

  bool _passwordVisible = false;
  bool _rePasswordVisible = false;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rePasswordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  List<String> locations = [];

  DateTime? _birthDate;

  @override
  void initState() {
    _presenter = UserInformationPresenter(this);
    _emailController.text = _presenter!.getEmail();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          width: size.width,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Gap(30),
              Text(
                'Complete Your Profile',
                style: AppTextStyles.profileTitle,
              ),
              const Gap(10),
              Stack(
                children: [
                  Container(
                    width: 92.0,
                    height: 92.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: NetworkImage(
                            "https://firebasestorage.googleapis.com/v0/b/rental-room-c34cb.appspot.com/o/avatar.jpg?alt=media&token=e9a9f6f6-9200-405a-98b4-5ae1130cd4bf"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
              ),
              const Gap(30),
              BackgroundContainer(
                alignment: Alignment.center,
                child: TextField(
                  readOnly: true,
                  controller: _emailController,
                  style: AppTextStyles.robo16Medi,
                  decoration: InputDecoration(
                    label: Text(
                      'Email',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: AppTextStyles.robo16Medi,
                  controller: _fullNameController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    label: Text(
                      'Full Name',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _phoneNumberController,
                  style: AppTextStyles.robo16Medi,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text(
                      'Phone Number',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  controller: _locationController,
                  style: AppTextStyles.robo16Medi,
                  decoration: InputDecoration(
                    label: Text(
                      'Address',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  controller: _birthDateController,
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  readOnly: true,
                  onTap: _datePicker,
                  style: AppTextStyles.robo16Medi,
                  keyboardType: TextInputType.datetime,
                  decoration: InputDecoration(
                    suffixIcon: IconButton(
                      onPressed: _datePicker,
                      icon: const Icon(FontAwesomeIcons.calendarDays),
                      color: AppPalette.hintText,
                    ),
                    label: Text(
                      'Birth Date',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: AppTextStyles.robo16Medi,
                  keyboardType: TextInputType.text,
                  controller: _passwordController,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    label: Text(
                      'Password',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                      icon: Icon(
                        _passwordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: AppPalette.hintText,
                        size: 18,
                      ),
                      color: AppPalette.hintText,
                    ),
                  ),
                ),
              ),
              BackgroundContainer(
                child: TextField(
                  onTapOutside: (event) {
                    FocusScope.of(context).unfocus();
                  },
                  style: AppTextStyles.robo16Medi,
                  controller: _rePasswordController,
                  keyboardType: TextInputType.text,
                  obscureText: !_rePasswordVisible,
                  decoration: InputDecoration(
                    label: Text(
                      'Confirm Password',
                      style: AppTextStyles.profileHintText,
                    ),
                    hintStyle: AppTextStyles.profileHintText,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(0),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _rePasswordVisible = !_rePasswordVisible;
                        });
                      },
                      icon: Icon(
                        _rePasswordVisible
                            ? FontAwesomeIcons.eyeSlash
                            : FontAwesomeIcons.eye,
                        color: AppPalette.hintText,
                        size: 18,
                      ),
                      color: AppPalette.hintText,
                    ),
                  ),
                ),
              ),
              const Gap(20),
              AuthButton(
                buttonName: 'DONE',
                onPressed: () {
                  _presenter!.handleConfirm(
                    name: _fullNameController.text.trim(),
                    email: _emailController.text.trim(),
                    phone: _phoneNumberController.text.trim(),
                    location: _locationController.text.trim(),
                    birthDate: _birthDate,
                    password: _passwordController.text.trim(),
                    rePassword: _rePasswordController.text.trim(),
                  );
                },
              ),
              const Gap(30),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _datePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _birthDateController.text =
            '${picked.day}/${picked.month}/${picked.year}';
      });
    }
  }

  @override
  void onConfirmFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onConfirmSucceeded() {
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
}
