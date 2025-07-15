// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class UserModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String id;
  final String? profileImageUrl;
  final String verificationStatus;
  final String? idDocumentUrl;
  final String address;

  const UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.id,
    this.profileImageUrl,
    required this.verificationStatus,
    this.idDocumentUrl,
    required this.address,
  });

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? id,
    String? profileImageUrl,
    String? verificationStatus,
    String? idDocumentUrl,
    String? address,
  }) {
    return UserModel(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      id: id ?? this.id,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'verificationStatus': verificationStatus,
      'idDocumentUrl': idDocumentUrl,
      'address': address,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'] ?? '',
      id: map['\$id'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      verificationStatus: map['verificationStatus'] ?? '',
      idDocumentUrl: map['idDocumentUrl'],
      address: map['address'] ?? '',
    );
  }
  @override
  String toString() {
    return 'UserModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email, id: $id, profileImageUrl: $profileImageUrl, verificationStatus: $verificationStatus, idDocumentUrl: $idDocumentUrl, address: $address,)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.id == id &&
        other.profileImageUrl == profileImageUrl &&
        other.verificationStatus == verificationStatus &&
        other.idDocumentUrl == idDocumentUrl &&
        other.address == address;
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        id.hashCode ^
        profileImageUrl.hashCode ^
        verificationStatus.hashCode ^
        idDocumentUrl.hashCode ^
        address.hashCode;
  }
}
