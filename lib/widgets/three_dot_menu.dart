import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/admin_login_screen.dart';
import '../screens/super_admin_screen.dart';

class ThreeDotMenu extends StatefulWidget {
  const ThreeDotMenu({Key? key}) : super(key: key);

  @override
  _ThreeDotMenuState createState() => _ThreeDotMenuState();
}

class _ThreeDotMenuState extends State<ThreeDotMenu> {
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out')),
    );

    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'admin') {
          final loggedIn = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
          );
          if (loggedIn == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Login Successful')),
            );
          }
        } else if (value == 'super') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SuperAdminScreen()),
          );
        } else if (value == 'logout') {
          await logout(context);
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(value: 'admin', child: Text('Admin Login')),
        PopupMenuItem(value: 'super', child: Text('Super Admin')),
        PopupMenuItem(value: 'logout', child: Text('Logout')),
      ],
    );
  }
}
