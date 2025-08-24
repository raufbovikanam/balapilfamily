import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model.dart';
import 'package:intl/intl.dart';

class AddMemberScreen extends StatefulWidget {
  static const routeName = '/add-member';
  final Member? member;
  final String parentId;

  const AddMemberScreen({super.key, this.member, this.parentId = ""});

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  final _nameController = TextEditingController();
  final _relationController = TextEditingController();
  final _dobController = TextEditingController();
  final _deathDateController = TextEditingController();
  final _ageController = TextEditingController();
  final _placeController = TextEditingController();
  final _jobController = TextEditingController();

  File? _selectedImage;
  String? _photoBase64;
  bool _isLoading = false;

  final Color _textColor = Colors.black;
  final Color _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    if (widget.member != null) {
      _nameController.text = widget.member!.name;
      _relationController.text = widget.member!.relation;
      _dobController.text = widget.member!.getFormattedDOB() ?? '';
      _deathDateController.text = widget.member!.getFormattedDeathDate() ?? '';
      _photoBase64 = widget.member!.photoBase64;
      _ageController.text = widget.member!.age?.toString() ?? '';
      _placeController.text = widget.member!.place ?? '';
      _jobController.text = widget.member!.job ?? '';
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) setState(() => _selectedImage = File(pickedFile.path));
  }

  Future<void> _convertImageToBase64() async {
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      _photoBase64 = base64Encode(bytes);
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    DateTime initialDate = DateTime.now();
    if (controller.text.isNotEmpty) {
      try {
        final parts = controller.text.split('-');
        initialDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      } catch (_) {}
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: _textColor,
            onPrimary: _backgroundColor,
            surface: _backgroundColor,
            onSurface: _textColor,
          ),
          dialogBackgroundColor: _backgroundColor,
        ),
        child: child!,
      ),
    );

    if (date != null) controller.text = DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _saveMember() async {
    final name = _nameController.text.trim();
    final relation = _relationController.text.trim();
    final dob = _dobController.text.trim();
    final deathDate = _deathDateController.text.trim();
    final ageText = _ageController.text.trim();
    final place = _placeController.text.trim();
    final job = _jobController.text.trim();

    if (name.isEmpty || relation.isEmpty || dob.isEmpty) {
      _showSnackBar('Please fill all required fields');
      return;
    }

    setState(() => _isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('adminId');
    if (adminId == null) {
      _showSnackBar('Admin not logged in');
      setState(() => _isLoading = false);
      return;
    }

    await _convertImageToBase64();

    final memberId = widget.member?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final data = {
      'name': name,
      'relation': relation,
      'dob': dob,
      'deathDate': deathDate.isNotEmpty ? deathDate : null,
      'photoBase64': _photoBase64 ?? '',
      'parentId': widget.parentId,
      'adminId': adminId,
      'age': ageText.isNotEmpty ? int.tryParse(ageText) : null,
      'place': place.isNotEmpty ? place : null,
      'job': job.isNotEmpty ? job : null,
    };

    final membersCollection = FirebaseFirestore.instance.collection('members');

    try {
      if (widget.member != null) {
        await membersCollection.doc(memberId).update(data);
        _showSnackBar('Updated $name');
      } else {
        await membersCollection.doc(memberId).set(data);
        _showSnackBar('Added $name');
        _clearFields();
      }
    } catch (e) {
      _showSnackBar('Error saving member: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: TextStyle(color: _textColor))),
    );
  }

  void _clearFields() {
    _nameController.clear();
    _relationController.clear();
    _dobController.clear();
    _deathDateController.clear();
    _ageController.clear();
    _placeController.clear();
    _jobController.clear();
    setState(() {
      _selectedImage = null;
      _photoBase64 = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.member != null;

    ImageProvider<Object>? avatarImage;
    if (_selectedImage != null) avatarImage = FileImage(_selectedImage!);
    else if (_photoBase64 != null && _photoBase64!.isNotEmpty)
      avatarImage = MemoryImage(base64Decode(_photoBase64!));

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Member' : 'Add Member', style: TextStyle(color: _textColor)),
        backgroundColor: _backgroundColor,
        iconTheme: IconThemeData(color: _textColor),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: avatarImage,
                child: avatarImage == null ? Icon(Icons.camera_alt, size: 40, color: _textColor) : null,
              ),
            ),
            const SizedBox(height: 20),
            ..._buildTextFields(),
            const SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator(color: _textColor)
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: _textColor,
                      ),
                      onPressed: _saveMember,
                      child: Text(isEditing ? 'Update Member' : 'Add Member'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTextFields() {
    return [
      _buildTextField(_nameController, 'Name'),
      const SizedBox(height: 10),
      _buildTextField(_relationController, 'Relation'),
      const SizedBox(height: 10),
      _buildTextField(_ageController, 'Age', keyboardType: TextInputType.number),
      const SizedBox(height: 10),
      _buildTextField(_placeController, 'Place'),
      const SizedBox(height: 10),
      _buildTextField(_jobController, 'Job'),
      const SizedBox(height: 10),
      _buildTextField(_dobController, 'DOB (YYYY-MM-DD)', readOnly: true, onTap: () => _pickDate(_dobController)),
      const SizedBox(height: 10),
      _buildTextField(_deathDateController, 'Death Date (optional)', readOnly: true, onTap: () => _pickDate(_deathDateController)),
    ];
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool readOnly = false, TextInputType keyboardType = TextInputType.text, VoidCallback? onTap}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      style: TextStyle(color: _textColor),
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: _textColor),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: _textColor)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: _textColor)),
        fillColor: _backgroundColor,
        filled: true,
      ),
    );
  }
}
