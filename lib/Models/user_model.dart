class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' hoặc 'user'
  final String? profileImage;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.profileImage,
    required this.createdAt,
  });

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      profileImage: map['profileImage'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Check if user is admin
  bool get isAdmin => role == 'admin';

  // Create a copy of UserModel with updated fields
  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? role,
    String? profileImage,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 