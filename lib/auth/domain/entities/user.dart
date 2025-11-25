import 'package:equatable/equatable.dart';

/// User entity
class User extends Equatable {
  final String uid;
  final String email;
  final String fullName;
  final String? phoneNumber;
  final String? photoUrl;
  final double totalSavings;
  final DateTime createdAt;

  const User({
    required this.uid,
    required this.email,
    required this.fullName,
    this.phoneNumber,
    this.photoUrl,
    this.totalSavings = 0.0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    uid,
    email,
    fullName,
    phoneNumber,
    photoUrl,
    totalSavings,
    createdAt,
  ];

  User copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? photoUrl,
    double? totalSavings,
    DateTime? createdAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      totalSavings: totalSavings ?? this.totalSavings,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
