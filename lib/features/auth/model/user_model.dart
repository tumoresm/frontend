import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String address;
  final String? idDocumentUrl;
  final String? profileImageUrl;
  final String verificationStatus;
  final List<String> myCompaniesPortfolio;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.address,
    this.idDocumentUrl,
    this.profileImageUrl,
    required this.verificationStatus,
    required this.myCompaniesPortfolio,
    required this.createdAt,
    required this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? address,
    String? idDocumentUrl,
    String? profileImageUrl,
    String? verificationStatus,
    List<String>? myCompaniesPortfolio,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      address: address ?? this.address,
      idDocumentUrl: idDocumentUrl ?? this.idDocumentUrl,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      myCompaniesPortfolio: myCompaniesPortfolio ?? this.myCompaniesPortfolio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'address': address,
      'idDocumentUrl': idDocumentUrl,
      'profileImageUrl': profileImageUrl,
      'verificationStatus': verificationStatus,
      'myCompaniesPortfolio': myCompaniesPortfolio,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['\$id'] ?? map['id'] ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      role: map['role']?.toString() ?? 'Rep',
      address: map['address']?.toString() ?? '',
      idDocumentUrl: map['idDocumentUrl']?.toString(),
      profileImageUrl: map['profileImageUrl']?.toString(),
      verificationStatus: map['verificationStatus']?.toString() ?? 'unverified',
      myCompaniesPortfolio: List<String>.from(map['myCompaniesPortfolio'] ?? []),
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, fullName: $fullName, phoneNumber: $phoneNumber, role: $role, address: $address, verificationStatus: $verificationStatus)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber &&
        other.role == role &&
        other.address == address &&
        other.idDocumentUrl == idDocumentUrl &&
        other.profileImageUrl == profileImageUrl &&
        other.verificationStatus == verificationStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        fullName.hashCode ^
        phoneNumber.hashCode ^
        role.hashCode ^
        address.hashCode ^
        idDocumentUrl.hashCode ^
        profileImageUrl.hashCode ^
        verificationStatus.hashCode;
  }
}