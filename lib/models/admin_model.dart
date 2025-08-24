class AdminModel {
  final String phone;
  final String name;

  AdminModel({required this.phone, required this.name});

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      phone: map['phone'] ?? '',
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'phone': phone,
      'name': name,
    };
  }

  AdminModel copyWith({String? phone, String? name}) {
    return AdminModel(
      phone: phone ?? this.phone,
      name: name ?? this.name,
    );
  }
}
