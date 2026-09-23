// lib/models/user_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { vendor, customer }

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? photoUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.photoUrl,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] == 'vendor' ? UserRole.vendor : UserRole.customer,
      photoUrl: data['photoUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'name': name,
        'email': email,
        'phone': phone,
        'role': role == UserRole.vendor ? 'vendor' : 'customer',
        'photoUrl': photoUrl,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
  }) =>
      UserModel(
        uid: uid,
        name: name ?? this.name,
        email: email,
        phone: phone ?? this.phone,
        role: role,
        photoUrl: photoUrl ?? this.photoUrl,
        createdAt: createdAt,
      );
}
