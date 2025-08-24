import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'super_admin_login_screen.dart';

class SuperAdminPanelScreen extends StatefulWidget {
  static const routeName = '/super-admin-panel';

  const SuperAdminPanelScreen({super.key});

  @override
  State<SuperAdminPanelScreen> createState() => _SuperAdminPanelScreenState();
}

class _SuperAdminPanelScreenState extends State<SuperAdminPanelScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isSuperAdmin');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, SuperAdminLoginScreen.routeName);
  }

  Future<void> _showAddEditDialog({String? docId}) async {
    _nameController.clear();
    _phoneController.clear();
    _passwordController.clear();

    if (docId != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('admins').doc(docId).get();
        final data = doc.data();
        _nameController.text = data?['name'] ?? '';
        _phoneController.text = data?['phone'] ?? '';
        _passwordController.text = data?['password'] ?? '';
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading admin: $e')));
        return;
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(docId == null ? 'Add Admin' : 'Edit Admin'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone'), keyboardType: TextInputType.phone),
                TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final name = _nameController.text.trim();
                final phone = _phoneController.text.trim();
                final password = _passwordController.text.trim();
                if (name.isEmpty || phone.isEmpty || password.isEmpty) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('All fields required')));
                  return;
                }

                try {
                  final col = FirebaseFirestore.instance.collection('admins');

                  // Unique phone check for new admin
                  final existing = await col.where('phone', isEqualTo: phone).get();
                  if (existing.docs.isNotEmpty && docId == null) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone number already exists')));
                    return;
                  }

                  if (docId == null) {
                    await col.add({'name': name, 'phone': phone, 'password': password});
                  } else {
                    await col.doc(docId).update({'name': name, 'phone': phone, 'password': password});
                  }

                  if (mounted) Navigator.pop(ctx);
                } catch (e) {
                  if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving admin: $e')));
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAdmin(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('admins').doc(docId).delete();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error deleting admin: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Super Admin Panel'),
        actions: [IconButton(icon: const Icon(Icons.logout), onPressed: _logout)],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('admins').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

          final admins = snapshot.data?.docs.toList() ?? [];
          admins.sort((a, b) => (a['name'] ?? '').compareTo(b['name'] ?? ''));

          if (admins.isEmpty) return const Center(child: Text('No admins found'));

          return ListView.builder(
            itemCount: admins.length,
            itemBuilder: (ctx, i) {
              final admin = admins[i];
              final id = admin.id;
              final data = admin.data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['name'] ?? ''),
                subtitle: Text(data['phone'] ?? ''),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: () => _showAddEditDialog(docId: id)),
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteAdmin(id)),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _showAddEditDialog(), child: const Icon(Icons.add)),
    );
  }
}
