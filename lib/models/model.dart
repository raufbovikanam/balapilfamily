import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Member {
  final String id;
  final String name;
  final String relation;
  final String? dob;
  final String? deathDate;
  final String? photoBase64;
  final String? parentId;
  final String? phone;
  final String adminId;
  final String? color;
  final int? age;      // 🔹 Age
  final String? place; // 🔹 Place
  final String? job;   // 🔹 Job
  List<Member> children;

  Member({
    required this.id,
    required this.name,
    required this.relation,
    this.dob,
    this.deathDate,
    this.photoBase64,
    this.parentId,
    this.phone,
    required this.adminId,
    this.color,
    this.age,
    this.place,
    this.job,
    List<Member>? children,
  }) : children = children ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'relation': relation,
      'dob': dob,
      'deathDate': deathDate,
      'photoBase64': photoBase64,
      'parentId': parentId,
      'phone': phone,
      'adminId': adminId,
      'color': color,
      'age': age,
      'place': place,
      'job': job,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    String? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Timestamp) return value.toDate().toIso8601String();
      return null;
    }

    return Member(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      relation: map['relation'] ?? '',
      dob: parseDate(map['dob']),
      deathDate: parseDate(map['deathDate']),
      photoBase64: map['photoBase64'] as String?,
      parentId: map['parentId'] as String?,
      phone: map['phone'] as String?,
      adminId: map['adminId'] ?? '',
      color: map['color'] as String?,
      age: map['age'] != null ? map['age'] as int : null,
      place: map['place'] as String?,
      job: map['job'] as String?,
      children: [],
    );
  }

  /// Returns age if dob is available and age field is null
  int? getAge() {
    if (age != null) return age;
    if (dob == null) return null;
    try {
      final birthDate = DateTime.parse(dob!);
      final today = DateTime.now();
      int calculatedAge = today.year - birthDate.year;
      if (today.month < birthDate.month || 
          (today.month == birthDate.month && today.day < birthDate.day)) {
        calculatedAge--;
      }
      return calculatedAge;
    } catch (_) {
      return null;
    }
  }

  /// Returns DOB in formatted style
  String? getFormattedDOB() {
    if (dob == null || dob!.isEmpty) return null;
    try {
      final date = DateTime.parse(dob!);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return dob;
    }
  }

  /// Returns Death Date in formatted style
  String? getFormattedDeathDate() {
    if (deathDate == null || deathDate!.isEmpty) return null;
    try {
      final date = DateTime.parse(deathDate!);
      return DateFormat('yyyy-MM-dd').format(date);
    } catch (_) {
      return deathDate;
    }
  }
}
