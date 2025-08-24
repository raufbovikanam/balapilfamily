import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/model.dart';
import 'member_detail_screen.dart';
import 'full_image_screen.dart';

class FamilyTreeScreen extends StatelessWidget {
  static const routeName = '/family-tree';
  static final Uri _youtubeUrl =
      Uri.parse('https://www.youtube.com/@oopaadIlakan?sub_confirmation=1');

  FamilyTreeScreen({super.key});
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Member>> fetchTopMembers() async {
    final snapshot = await _firestore
        .collection('members')
        .where('parentId', isEqualTo: '') // root members
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Member.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Future<List<Member>> fetchChildren(String parentId) async {
    final snapshot = await _firestore
        .collection('members')
        .where('parentId', isEqualTo: parentId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Member.fromMap({...doc.data(), 'id': doc.id}))
        .toList();
  }

  Widget buildTree(BuildContext context, Member member) {
    return FutureBuilder<List<Member>>(
      future: fetchChildren(member.id),
      builder: (context, snapshot) {
        final children = snapshot.data ?? [];

        return ExpansionTile(
          leading: _buildAvatar(context, member.photoBase64),
          title: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberDetailsScreen(member: member),
                ),
              );
            },
            child: Text(
              member.name,
              style: const TextStyle(color: Colors.yellowAccent),
            ),
          ),
          children: children.isNotEmpty
              ? children.map((child) => buildTree(context, child)).toList()
              : [
                  const ListTile(
                    title: Text(
                      'No children',
                      style: TextStyle(color: Colors.yellowAccent),
                    ),
                  )
                ],
        );
      },
    );
  }

  Widget _buildAvatar(BuildContext context, String? photoBase64,
      {double radius = 25}) {
    final avatar = (photoBase64 != null && photoBase64.isNotEmpty)
        ? CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(base64Decode(photoBase64)),
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: Colors.black,
            child: const Icon(Icons.person, color: Colors.yellowAccent),
          );

    return GestureDetector(
      onTap: () {
        if (photoBase64 != null && photoBase64.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FullImageScreen(photoBase64: photoBase64),
            ),
          );
        }
      },
      child: avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Ummar Khadeeja Family Tree',
          style: TextStyle(
            fontFamily: 'Baloo',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.yellowAccent,
          ),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.yellowAccent),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundImage: AssetImage('assets/images/ummar_khadeeja.jpg'),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ummar Khadeeja',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                fontFamily: 'Baloo',
                color: Colors.yellowAccent,
              ),
            ),
            const SizedBox(height: 24),
            FutureBuilder<List<Member>>(
              future: fetchTopMembers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: Colors.yellowAccent),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.yellowAccent),
                    ),
                  );
                }
                final topMembers = snapshot.data ?? [];
                if (topMembers.isEmpty) {
                  return const Text(
                    'No members found',
                    style: TextStyle(color: Colors.yellowAccent),
                  );
                }
                return Column(
                  children: topMembers
                      .map((member) => buildTree(context, member))
                      .toList(),
                );
              },
            ),
            const SizedBox(height: 30),
            InkWell(
              onTap: () async {
                if (await canLaunchUrl(_youtubeUrl)) {
                  await launchUrl(
                    _youtubeUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not launch YouTube',
                        style: TextStyle(color: Colors.yellowAccent),
                      ),
                    ),
                  );
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/icons/app_icon.png',
                    height: 26,
                    width: 26,
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Subscribe Oopaad Ilakan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Baloo',
                      decoration: TextDecoration.underline,
                      color: Colors.yellowAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(10),
        child: Text(
          'Created by Rauf Bovikanam',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
