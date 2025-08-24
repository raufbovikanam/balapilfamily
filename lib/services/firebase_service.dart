import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> addAdmin(String name, String phone, String password) async {
    await _firestore.collection('admins').doc(phone).set({
      'name': name,
      'phone': phone,
      'password': password,
    });
  }

  Future<bool> isAdminLoginValid(String phone, String password) async {
    final doc = await _firestore.collection('admins').doc(phone).get();
    if (doc.exists) {
      final data = doc.data()!;
      if (data['password'] == password) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAdmin', true);
        await prefs.setString('adminId', phone);
        return true;
      }
    }
    return false;
  }

  Future<bool> isSuperAdminLoginValid(String phone, String password) async {
    if (phone == '8281308603' && password == 'Balapil786') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isSuperAdmin', true);
      return true;
    }
    return false;
  }

  Future<bool> isLoggedInAsAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isAdmin') ?? false;
  }

  Future<bool> isLoggedInAsSuperAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isSuperAdmin') ?? false;
  }

  Future<String> uploadImage(XFile imageFile) async {
    final ref = _storage.ref().child('member_images').child(const Uuid().v4());
    final file = File(imageFile.path);
    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  Future<void> addMember(Member member) async {
    final prefs = await SharedPreferences.getInstance();
    final adminId = prefs.getString('adminId');
    if (adminId == null || adminId.isEmpty) {
      throw Exception('Admin not logged in');
    }

    final id = const Uuid().v4();
    final memberMap = member.toMap();
    memberMap['id'] = id;
    memberMap['adminId'] = adminId;
    memberMap['timestamp'] = FieldValue.serverTimestamp();

    await _firestore.collection('members').doc(id).set(memberMap);
  }

  Future<void> updateMember(String id, Member member) async {
    final map = member.toMap();
    map['timestamp'] = FieldValue.serverTimestamp();
    await _firestore.collection('members').doc(id).update(map);
  }

  Future<void> deleteMember(String id) async {
    await _firestore.collection('members').doc(id).delete();
  }

  Stream<List<Member>> getMembersByAdmin(String adminId) {
    return _firestore
        .collection('members')
        .where('adminId', isEqualTo: adminId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Member.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  Future<List<Map<String, dynamic>>> getAllAdmins() async {
    final snapshot = await _firestore.collection('admins').get();
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> updateAdminPassword(String phone, String newPassword) async {
    await _firestore.collection('admins').doc(phone).update({'password': newPassword});
  }

  Future<void> updateAdminPhone(String oldPhone, String newPhone) async {
    final oldDoc = await _firestore.collection('admins').doc(oldPhone).get();
    if (oldDoc.exists) {
      final data = oldDoc.data()!;
      data['phone'] = newPhone;
      await _firestore.collection('admins').doc(newPhone).set(data);
      await _firestore.collection('admins').doc(oldPhone).delete();

      final prefs = await SharedPreferences.getInstance();
      final adminId = prefs.getString('adminId');
      if (adminId == oldPhone) {
        await prefs.setString('adminId', newPhone);
      }
    }
  }

  Future<void> deleteAdmin(String phone) async {
    await _firestore.collection('admins').doc(phone).delete();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAdmin');
    await prefs.remove('adminId');
    await prefs.remove('isSuperAdmin');
  }
}
