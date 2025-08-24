import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/model.dart';
import 'add_member_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});
  static const routeName = '/admin-panel';

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  String? _adminId;
  bool _isSuperAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _adminId = prefs.getString('adminId');
      _isSuperAdmin = prefs.getBool('isSuperAdmin') ?? false;
    });
  }

  Widget _buildMemberTree(Member member, List<Member> allMembers) {
    final children = allMembers.where((m) => m.parentId == member.id).toList();
    final dob = member.getFormattedDOB() ?? 'N/A';
    final death = member.getFormattedDeathDate();
    final age = member.getAge() != null ? 'Age: ${member.getAge()}' : '';
    final place = member.place != null && member.place!.isNotEmpty ? 'Place: ${member.place}' : '';
    final job = member.job != null && member.job!.isNotEmpty ? 'Job: ${member.job}' : '';

    const textColor = Colors.white;
    const backgroundColor = Colors.black;

    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: backgroundColor, // black background
            child: ListTile(
              leading: (member.photoBase64 != null && member.photoBase64!.isNotEmpty)
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(base64Decode(member.photoBase64!)))
                  : const CircleAvatar(child: Icon(Icons.person, color: Colors.white)),
              title: Text(member.name, style: const TextStyle(color: textColor)),
              subtitle: Text(
                death != null
                    ? 'Relation: ${member.relation}\nDOB: $dob\nDOD: $death\n$age\n$place\n$job'
                    : 'Relation: ${member.relation}\nDOB: $dob\n$age\n$place\n$job',
                style: const TextStyle(color: textColor),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.add, color: Colors.white),
                    tooltip: 'Add Child',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AddMemberScreen(parentId: member.id)),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AddMemberScreen(member: member, parentId: member.parentId ?? ""),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.white),
                    onPressed: () async {
                      final hasChildren = children.isNotEmpty;
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Delete Member"),
                          content: Text(
                            hasChildren
                                ? "This member has children. Delete all members of this branch?"
                                : "Are you sure you want to delete ${member.name}?",
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel")),
                            TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Delete")),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _deleteMemberRecursively(member.id, allMembers);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          if (children.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                children: children.map((child) => _buildMemberTree(child, allMembers)).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteMemberRecursively(String memberId, List<Member> allMembers) async {
    final children = allMembers.where((m) => m.parentId == memberId).toList();
    for (var child in children) {
      await _deleteMemberRecursively(child.id, allMembers);
    }
    await FirebaseFirestore.instance.collection('members').doc(memberId).delete();
  }

  @override
  Widget build(BuildContext context) {
    if (_adminId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Family Tree"),
        actions: [
          if (_isSuperAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Manage Admins',
              onPressed: () {},
            ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Member',
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const AddMemberScreen(parentId: "")));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('members')
            .where('adminId', isEqualTo: _adminId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading members: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) return const Center(child: Text('No members found.'));

          final members = docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            return Member.fromMap({
              ...data,
              'id': d.id,
              'dob': data['dob']?.toString(),
              'deathDate': data['deathDate']?.toString(),
              'place': data['place']?.toString() ?? '',
              'job': data['job']?.toString() ?? '',
            });
          }).toList();

          final roots =
              members.where((m) => m.parentId == null || m.parentId!.isEmpty).toList();

          return ListView(
            children: roots.map((root) => _buildMemberTree(root, members)).toList(),
          );
        },
      ),
    );
  }
}
