import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../widgets/app_drawer.dart';
import '../utils/constants.dart';

class SuperAdminScreen extends StatefulWidget {
  static const routeName = '/super-admin-panel';

  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  final FirebaseService firebaseService = FirebaseService();
  late Future<List<Map<String, dynamic>>> _adminsFuture;

  // ✅ Define textColor here
  final Color textColor = Colors.white;

  @override
  void initState() {
    super.initState();
    _loadAdmins();
  }

  void _loadAdmins() {
    setState(() {
      _adminsFuture = firebaseService.getAllAdmins();
    });
  }

  void _showAddAdminDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscure = true;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          backgroundColor: backgroundColor,
          title: Text("Add Admin", style: TextStyle(color: textColor)),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: 'Name', labelStyle: TextStyle(color: textColor)),
                  style: TextStyle(color: textColor),
                ),
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                      labelText: 'Phone Number', labelStyle: TextStyle(color: textColor)),
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: textColor),
                ),
                TextField(
                  controller: passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: textColor),
                    suffixIcon: IconButton(
                      icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: textColor),
                      onPressed: () => setState(() => obscure = !obscure),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: secondaryColor)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
              onPressed: () async {
                final name = nameController.text.trim();
                final phone = phoneController.text.trim();
                final password = passwordController.text.trim();
                if (name.isEmpty || phone.isEmpty || password.isEmpty) return;

                await firebaseService.addAdmin(name, phone, password);
                Navigator.pop(context);
                _loadAdmins();
                ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(content: Text('Admin added')));
              },
              child: const Text("Add", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  void _showEditDialog(Map<String, dynamic> admin) {
    final phoneController = TextEditingController(text: admin['phone']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text("Edit Admin", style: TextStyle(color: textColor)),
        content: TextField(
          controller: phoneController,
          decoration: InputDecoration(
              labelText: 'Phone Number', labelStyle: TextStyle(color: textColor)),
          keyboardType: TextInputType.phone,
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: secondaryColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
            onPressed: () async {
              final newPhone = phoneController.text.trim();
              if (newPhone.isEmpty) return;

              await firebaseService.updateAdminPhone(admin['phone'], newPhone);
              Navigator.pop(context);
              _loadAdmins();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Admin updated')));
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPasswordChangeDialog(String phone) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text("Change Password", style: TextStyle(color: textColor)),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: InputDecoration(
              labelText: 'New Password', labelStyle: TextStyle(color: textColor)),
          style: TextStyle(color: textColor),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: secondaryColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
            onPressed: () async {
              final newPass = controller.text.trim();
              if (newPass.isEmpty) return;

              await firebaseService.updateAdminPassword(phone, newPass);
              Navigator.pop(context);
              _loadAdmins();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Password updated')));
            },
            child: const Text("Update", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String phone) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: backgroundColor,
        title: Text("Delete Admin", style: TextStyle(color: textColor)),
        content: Text("Are you sure you want to delete this admin?", style: TextStyle(color: textColor)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel", style: TextStyle(color: secondaryColor))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: secondaryColor),
            onPressed: () async {
              await firebaseService.deleteAdmin(phone);
              Navigator.pop(context);
              _loadAdmins();
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Admin deleted')));
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text("Super Admin Panel"),
          backgroundColor: primaryColor,
        ),
        drawer: const AppDrawer(),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _adminsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
            }
            final admins = snapshot.data ?? [];
            if (admins.isEmpty) return Center(child: Text('No admins found.', style: TextStyle(color: textColor)));

            return ListView.builder(
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text("${admin['name']} (${admin['phone']})", style: TextStyle(color: textColor)),
                    trailing: PopupMenuButton<String>(
                      color: Colors.grey[800],
                      onSelected: (value) {
                        if (value == 'edit') _showEditDialog(admin);
                        if (value == 'password') _showPasswordChangeDialog(admin['phone']);
                        if (value == 'delete') _confirmDelete(admin['phone']);
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'password', child: Text('Change Password')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: secondaryColor,
          onPressed: _showAddAdminDialog,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
