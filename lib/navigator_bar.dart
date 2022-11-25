import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solares/login.dart';
import 'package:solares/pages/dashboard/dashboard.dart';
import 'package:solares/pages/qr/qr_code.dart';
/* import 'package:solares/pages/reports.dart'; */
import 'package:solares/pages/users.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  late SharedPreferences sharedPreferences;

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString('token') == null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => const Login(),
        ),
        (Route<dynamic> route) => false,
      );
    }
  }

  int _selectedIndex = 0;

  final GlobalKey<CurvedNavigationBarState> _bottomNavigationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          index: 0,
          height: 60.0,
          items: const <Widget>[
            Icon(Icons.dashboard, size: 30),
            Icon(Icons.qr_code, size: 30),
            /* Icon(Icons.summarize, size: 30), */
            Icon(Icons.person, size: 30),
          ],
          color: Colors.white,
          buttonBackgroundColor: Colors.white,
          backgroundColor: const Color.fromARGB(255, 25, 33, 61),
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 600),
          onTap: (int tappedIndex) {
            setState(() {
              _selectedIndex = tappedIndex;
            });
          },
          letIndexChange: (index) => true,
        ),
        body: SafeArea(
          child: IndexedStack(
            index: _selectedIndex,
            children: const [Dashboard(), QRCode(), /* Reports(), */ Users()],
          ),
        ));
  }
}
