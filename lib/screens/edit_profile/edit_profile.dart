import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:gap/gap.dart';
import 'package:motor_secure/core/constants/app_palette.dart';
import 'package:motor_secure/core/constants/art.dart';
import 'package:motor_secure/core/styles/app_text_styles.dart';
import 'package:motor_secure/screens/edit_profile/edit_profile_screen_contract.dart';
import 'package:motor_secure/screens/edit_profile/edit_profile_screen_presenter.dart';
import 'package:motor_secure/screens/profile/profile_view.dart';
import 'package:motor_secure/widgets/background_container.dart';
import 'package:motor_secure/widgets/button/accept_button.dart';
import 'package:motor_secure/widgets/button/cancel_button.dart';
import '../../widgets/util_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  static const String routeName = 'edit_profile_screen';

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    implements EditProfileScreenContract {
  EditProfileScreenPresenter? _presenter;

  String name = "";
  String email = "";
  DateTime? _dob;
  String phone = "";
  String address = "";
  bool isLoading = true;

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    _presenter = EditProfileScreenPresenter(this);
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
          'EDIT PROFILE',
          style: AppTextStyles.profileTitle,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: isLoading
            ? UtilWidgets.getLoadingWidget()
            : Container(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () async {},
                        child: Container(
                          height: 132,
                          width: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: AssetImage(Art.avatar),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Gap(10),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        name,
                        style: AppTextStyles.profileName,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      child: Text(email, style: AppTextStyles.robo16Medi),
                    ),
                    const Gap(20),
                    BackgroundContainer(
                      child: TextField(
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        style: AppTextStyles.robo16Medi,
                        keyboardType: TextInputType.text,
                        controller: _fullNameController,
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
                        controller: _birthDateController,
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        style: AppTextStyles.robo16Medi,
                        keyboardType: TextInputType.datetime,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && picked != _dob) {
                                setState(() {
                                  _dob = picked;
                                  _birthDateController.text =
                                      '${picked.day}/${picked.month}/${picked.year}';
                                });
                              }
                            },
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
                        controller: _addressController,
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
                        onTapOutside: (event) {
                          FocusScope.of(context).unfocus();
                        },
                        style: AppTextStyles.robo16Medi,
                        keyboardType: TextInputType.number,
                        controller: _phoneController,
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
                    const Gap(15),
                    AcceptButton(
                      onPressed: () async {
                        await _presenter?.handleSave(
                          name: _fullNameController.text.trim(),
                          dob: _dob!,
                          address: _addressController.text.trim(),
                          phone: _phoneController.text.trim(),
                        );
                      },
                      name: 'Save',
                    ),
                    const Gap(10),
                    CancelButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Gap(20),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void onLoadDataSucceeded() {
    setState(() {
      _dob = _presenter!.user!.dob;
      email = _presenter!.user!.email;
      name = _presenter!.user!.name;
      _fullNameController.text = _presenter!.user!.name;
      _phoneController.text = _presenter!.user!.phone;
      _birthDateController.text = '${_dob!.day}/${_dob!.month}/${_dob!.year}';
      address = _presenter!.user!.address;
      _addressController.text = _presenter!.user!.address;
      isLoading = false;
    });
  }

  @override
  void onSaveFailed(String message) {
    UtilWidgets.createSnackBar(context, message);
  }

  @override
  void onSaveSucceeded() {
    setState(() {
      name = _presenter!.user!.name;
      email = _presenter!.user!.email;
      phone = _presenter!.user!.phone;
      address = _presenter!.user!.address;
      _dob = _presenter!.user!.dob;
      isLoading = false;
    });
    UtilWidgets.createSnackBar(context, "Save successfully!");
    Navigator.of(context).pushNamed(ProfileView.routeName);
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
  void onPickAvatar() {
    setState(() {});
  }
}
