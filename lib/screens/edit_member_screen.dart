import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/member.dart';
import 'package:intl/intl.dart';

class EditMemberScreen extends StatefulWidget {
  final Member member;
  const EditMemberScreen({super.key, required this.member});

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final nameController = TextEditingController();
  final relationController = TextEditingController();
  final dobController = TextEditingController();
  final phoneController = TextEditingController();
  final colorController = TextEditingController();
  final jobController = TextEditingController();
  final placeController = TextEditingController();
  File? imageFile;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    nameController.text = widget.member.name;
    relationController.text = widget.member.relation;
    dobController.text = widget.member.dob ?? '';
    phoneController.text = widget.member.phone ?? '';
    colorController.text = widget.member.color ?? '';
    jobController.text = widget.member.job ?? '';
    placeController.text = widget.member.place ?? '';
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => imageFile = File(picked.path));
    }
  }

  String? getBase64Image() {
    if (imageFile != null) {
      final bytes = imageFile!.readAsBytesSync();
      return base64Encode(bytes);
    }
    return widget.member.photoBase64;
  }

  Future<void> pickDOB() async {
    DateTime initialDate = DateTime.now();
    if (dobController.text.isNotEmpty) {
      try {
        initialDate = DateTime.parse(dobController.text);
      } catch (_) {}
    }

    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(date);
    }
  }

  int? calculateAge() {
    if (dobController.text.isEmpty) return null;
    try {
      final dob = DateTime.parse(dobController.text);
      final now = DateTime.now();
      int age = now.year - dob.year;
      if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
      return age;
    } catch (_) {
      return null;
    }
  }

  Future<void> updateMember() async {
    final name = nameController.text.trim();
    final relation = relationController.text.trim();
    final dob = dobController.text.trim();
    final phone = phoneController.text.trim();
    final color = colorController.text.trim();
    final job = jobController.text.trim();
    final place = placeController.text.trim();

    if (name.isEmpty || relation.isEmpty || dob.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => isLoading = true);
    final photoBase64 = getBase64Image();

    final updatedMember = Member(
      id: widget.member.id,
      name: name,
      relation: relation,
      dob: dob,
      deathDate: widget.member.deathDate,
      photoBase64: photoBase64,
      parentId: widget.member.parentId,
      phone: phone.isNotEmpty ? phone : null,
      adminId: widget.member.adminId,
      color: color.isNotEmpty ? color : null,
      job: job.isNotEmpty ? job : null,
      place: place.isNotEmpty ? place : null,
    );

    try {
      await FirebaseFirestore.instance
          .collection('members')
          .doc(widget.member.id)
          .update(updatedMember.toMap());

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to update member: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageFile != null) {
      imageProvider = FileImage(imageFile!);
    } else if (widget.member.photoBase64 != null && widget.member.photoBase64!.isNotEmpty) {
      imageProvider = MemoryImage(base64Decode(widget.member.photoBase64!));
    }

    final age = calculateAge();

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Edit Member')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: imageProvider,
                  child: imageProvider == null
                      ? const Icon(Icons.add_a_photo, size: 32)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              const SizedBox(height: 12),
              TextField(controller: relationController, decoration: const InputDecoration(labelText: 'Relation')),
              const SizedBox(height: 12),
              TextField(
                controller: dobController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'DOB (YYYY-MM-DD)',
                  suffixText: age != null ? '$age yrs' : null,
                ),
                onTap: pickDOB,
              ),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone (optional)')),
              const SizedBox(height: 12),
              TextField(controller: colorController, decoration: const InputDecoration(labelText: 'Color (optional)')),
              const SizedBox(height: 12),
              TextField(controller: jobController, decoration: const InputDecoration(labelText: 'Job (optional)')),
              const SizedBox(height: 12),
              TextField(controller: placeController, decoration: const InputDecoration(labelText: 'Place (optional)')),
              const SizedBox(height: 24),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: updateMember,
                      child: const Text('Update'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
