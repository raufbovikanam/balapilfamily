import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'screens/add_member_screen.dart';
import 'screens/admin_login_screen.dart';
import 'screens/admin_panel_screen.dart';
import 'screens/family_tree_screen.dart';
import 'screens/redirect_screen.dart';
import 'screens/super_admin_login_screen.dart';
import 'screens/super_admin_screen.dart';
import 'screens/super_admin_panel_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/my_home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Safe Firebase initialization for Android, iOS, Web
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint('Firebase initialization skipped: $e');
  }

  runApp(const BalapilApp());
}

class BalapilApp extends StatelessWidget {
  const BalapilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Balapil Family',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: RedirectScreen.routeName,
      routes: {
        WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        AdminLoginScreen.routeName: (context) => const AdminLoginScreen(),
        SuperAdminLoginScreen.routeName: (context) => const SuperAdminLoginScreen(),
        AdminPanelScreen.routeName: (context) => const AdminPanelScreen(),
        SuperAdminScreen.routeName: (context) => const SuperAdminScreen(),
        SuperAdminPanelScreen.routeName: (context) => const SuperAdminPanelScreen(),
        AddMemberScreen.routeName: (context) => const AddMemberScreen(),
        FamilyTreeScreen.routeName: (context) => FamilyTreeScreen(),
        RedirectScreen.routeName: (context) => const RedirectScreen(),
        '/firebase_demo': (context) => MyHomePage(),
      },
    );
  }
}
