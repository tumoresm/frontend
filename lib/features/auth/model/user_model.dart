// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:fieldforce/core/logger.dart';

@immutable
class UserModel {
  final String fullName;
  final String phoneNumber;
  final String email;
  final String address;
  final String id;
  final String? profileImageUrl;
  final String? idDocumentUrl;
  final String verificationStatus;
  final String role;

  final List<String> myCompaniesPortfolio; // List of company IDs

  const UserModel({
    required this.fullName,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.id,
    this.profileImageUrl,
    this.idDocumentUrl,
    required this.verificationStatus,
    required this.role,
    this.myCompaniesPortfolio = const [],
  });

  UserModel copyWith({
    String? fullName,
    String? phoneNumber,
    String? email,
    String? address,
    String? id,
    String? profileImageUrl,
    String? idDocumentUrl,
    String? verificationStatus,
    String? role,
    List<String>? myCompaniesPortfolio,
  }) =>
      UserModel(
        fullName: fullName ?? this.fullName,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        email: email ?? this.email,
        id: id ?? this.id,
        profileImageUrl: profileImageUrl ?? this.profileImageUrl,
        idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
        verificationStatus: verificationStatus ?? this.verificationStatus,
        role: role ?? this.role,
        myCompaniesPortfolio: myCompaniesPortfolio ?? this.myCompaniesPortfolio,
        address: address ?? this.address,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'idDocumentUrl': idDocumentUrl,
        'verificationStatus': verificationStatus,
        'role': role,
        'myCompaniesPortfolio': myCompaniesPortfolio,
      };

  factory UserModel.fromMap(Map<String, dynamic> map) {
    try {
      return UserModel(
        fullName: map['fullName'] ?? '',
        phoneNumber: map['phoneNumber'] ?? '',
        email: map['email'] ?? '',
        address: map['address'] ?? '',
        id: map['\$id'] ?? '',
        profileImageUrl: map['profileImageUrl'],
        idDocumentUrl: map['idDocumentUrl'],
        verificationStatus: map['verificationStatus'] ?? '',
        role: map['role'] ?? '',
        myCompaniesPortfolio: map['myCompaniesPortfolio'] != null 
            ? List<String>.from(map['myCompaniesPortfolio']) 
            : [],
      );
    } catch (e) {
      Loggers.api.error('Error parsing UserModel from map', error: e);
      Loggers.api.debug('Map data: $map');
      rethrow;
    }
  }
  @override
  String toString() =>
      'UserModel(fullName: $fullName, phoneNumber: $phoneNumber, email: $email,address: $address, id: $id, profileImageUrl: $profileImageUrl, idDocumentUrl: $idDocumentUrl, verificationStatus: $verificationStatus, role: $role)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserModel &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.email == email &&
        other.id == id &&
        other.profileImageUrl == profileImageUrl &&
        other.idDocumentUrl == idDocumentUrl &&
        other.verificationStatus == verificationStatus &&
        other.role == role &&
        other.address == address &&
        listEquals(other.myCompaniesPortfolio, myCompaniesPortfolio);
  }

  @override
  int get hashCode {
    return fullName.hashCode ^
        phoneNumber.hashCode ^
        email.hashCode ^
        id.hashCode ^
        (profileImageUrl?.hashCode ?? 0) ^
        (idDocumentUrl?.hashCode ?? 0) ^
        verificationStatus.hashCode ^
        role.hashCode ^
        address.hashCode ^
        myCompaniesPortfolio.hashCode;
  }
}
