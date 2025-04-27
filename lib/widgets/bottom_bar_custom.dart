import 'package:flutter/material.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motor_secure/screens/home/home_view.dart';
import 'package:motor_secure/screens/notifications/notifications_view.dart';
import 'package:motor_secure/screens/profile/profile_view.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';

class BottomBarCustom extends StatelessWidget {
  final int currentIndex;
  const BottomBarCustom({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return StylishBottomBar(
      elevation: 10,
      iconSpace: 1.2,
      items: [
        BottomBarItem(
          icon: const Icon(Icons.notifications),
          title: Text(
            'Notifications',
            style: GoogleFonts.roboto(
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.lightBlue,
        ),
        BottomBarItem(
          icon: const Icon(FontAwesomeIcons.motorcycle),
          title: Text(
            'Home',
            style: GoogleFonts.roboto(
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.green,
        ),
        BottomBarItem(
          icon: const Icon(Icons.person),
          title: Text(
            'Profile',
            style: GoogleFonts.roboto(
              fontSize: 14,
            ),
          ),
          backgroundColor: Colors.pinkAccent,
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 0) {
          Navigator.of(context).pushNamed(NotificationsView.routeName);
        } else if (index == 1) {
          Navigator.of(context).pushNamed(HomeView.routeName);
        } else if (index == 2) {
          Navigator.of(context).pushNamed(ProfileView.routeName);
        } else {}
      },
      option: BubbleBarOptions(
        iconSize: 40,
        opacity: 0.18,
        barStyle: BubbleBarStyle.vertical,
      ),
    );
  }
}
