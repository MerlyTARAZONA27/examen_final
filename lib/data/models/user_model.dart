class UserModel {
  final String? id;
  final DateTime? createdAt;
  final String name;
  final String email;
  final String password;

  UserModel({
    this.id,
    this.createdAt,
    required this.name,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : null,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'email': email,
      'password': password,
    };
    if (id != null) data['id'] = id;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    return data;
  }
}
