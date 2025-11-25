import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:savesmart/features/auth/domain/entities/user.dart';

/// User model for data layer
class UserModel extends User {
  const UserModel({
    required super.uid,
    required super.email,
    required super.fullName,
    super.phoneNumber,
    super.photoUrl,
    super.totalSavings,
    required super.createdAt,
  });

  /// Convert from domain entity
  factory UserModel.fromEntity(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      photoUrl: user.photoUrl,
      totalSavings: user.totalSavings,
      createdAt: user.createdAt,
    );
  }

  /// Convert from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UserModel(
      uid: doc.id,
      email: data['email'] as String,
      fullName: data['fullName'] as String,
      phoneNumber: data['phoneNumber'] as String?,
      photoUrl: data['photoUrl'] as String?,
      totalSavings: (data['totalSavings'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'totalSavings': totalSavings,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Convert from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String?,
      photoUrl: json['photoUrl'] as String?,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'totalSavings': totalSavings,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
