import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model.dart';
import 'full_image_screen.dart';

class MemberDetailsScreen extends StatelessWidget {
  final Member member;

  const MemberDetailsScreen({super.key, required this.member});

  Future<List<Member>> fetchChildren(String parentId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('members')
        .where('parentId', isEqualTo: parentId)
        .orderBy('name')
        .get();

    return snapshot.docs
        .map((doc) => Member.fromMap({...doc.data(), "id": doc.id}))
        .toList();
  }

  Widget _buildAvatar(BuildContext context, String? photoBase64,
      {double radius = 50}) {
    final avatar = (photoBase64 != null && photoBase64.isNotEmpty)
        ? CircleAvatar(
            radius: radius,
            backgroundImage: MemoryImage(base64Decode(photoBase64)),
          )
        : CircleAvatar(
            radius: radius,
            child: const Icon(Icons.person,
                size: 40, color: Colors.yellowAccent),
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
    const Color textColor = Colors.yellowAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(member.name, style: const TextStyle(color: textColor)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          _buildAvatar(context, member.photoBase64, radius: 60),
          const SizedBox(height: 10),
          Text(
            member.name,
            style: const TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          ),
          const Divider(height: 40, color: Colors.yellowAccent),
          const Text(
            'Children',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<List<Member>>(
              future: fetchChildren(member.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Colors.yellowAccent));
                }
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: textColor),
                  ));
                }
                final children = snapshot.data ?? [];
                if (children.isEmpty) {
                  return const Center(
                    child: Text(
                      'No children found',
                      style: TextStyle(fontSize: 16, color: textColor),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    return ListTile(
                      leading: _buildAvatar(context, child.photoBase64, radius: 25),
                      title: Text(child.name,
                          style: const TextStyle(color: textColor)),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          color: textColor),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MemberDetailsScreen(member: child),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
