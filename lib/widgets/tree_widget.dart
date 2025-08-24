import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model.dart';
import '../screens/member_details_screen.dart';

class TreeWidget extends StatelessWidget {
  const TreeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('members')
          .where('parentId', isEqualTo: null)
          .orderBy('name')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No family members found.'));
        }

        final members = snapshot.data!.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final mapWithId = Map<String, dynamic>.from(data);
          mapWithId['id'] = doc.id;
          return Member.fromMap(mapWithId);
        }).toList();

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: members.length,
          itemBuilder: (context, index) => _buildMemberTile(context, members[index]),
        );
      },
    );
  }

  Widget _buildMemberTile(BuildContext context, Member member) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MemberDetailsScreen(member: member),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: member.photoUrl != null
                  ? NetworkImage(member.photoUrl!)
                  : const AssetImage('assets/images/default.png') as ImageProvider,
              child: member.photoUrl == null ? const Icon(Icons.person) : null,
            ),
            const SizedBox(width: 10),
            Text(
              member.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                fontFamily: 'Baloo',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
