import 'package:flutter/material.dart';
import 'package:balapil_family/screens/family_tree_screen.dart';
import 'package:balapil_family/screens/admin_login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../widgets/app_drawer.dart';

class WelcomeScreen extends StatelessWidget {
  static const routeName = '/welcome';
  const WelcomeScreen({super.key});

  Future<void> _launchYouTubeChannel() async {
    const url = 'https://www.youtube.com/@oopaadIlakan?sub_confirmation=1';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final membersCollection = FirebaseFirestore.instance.collection('members');

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          "Welcome",
          style: TextStyle(color: Colors.yellowAccent),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellowAccent),
      ),
      drawer: const AppDrawer(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Name at the top
              const Text(
                'Ummar Khadeeja',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.yellowAccent,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Total Members in center
              StreamBuilder<QuerySnapshot>(
                stream: membersCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(color: Colors.yellowAccent);
                  }
                  if (snapshot.hasError) {
                    return Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.yellowAccent),
                    );
                  }

                  final totalMembers = snapshot.data?.docs.length ?? 0;
                  return Text(
                    'Total Members: $totalMembers',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellowAccent,
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // View Family Tree Button with border
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.yellowAccent, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.yellowAccent,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FamilyTreeScreen(),
                      ),
                    );
                  },
                  child: const Text('View Family Tree'),
                ),
              ),
              const SizedBox(height: 15),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size.fromHeight(45),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, AdminLoginScreen.routeName);
                },
                child: const Text(
                  'Admin Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),

              const SizedBox(height: 30),
              TextButton.icon(
                onPressed: _launchYouTubeChannel,
                icon: const Icon(Icons.video_library, size: 24, color: Colors.yellowAccent),
                label: const Text(
                  "Watch on YouTube",
                  style: TextStyle(color: Colors.yellowAccent, fontSize: 16),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Created by 8281308603',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
