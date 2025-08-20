import 'dart:convert';

class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String role;
  final String address;
  final String? idNumber;
  final String? profileImage;
  final String? selectedAvatar; // Avatar identifier for avatar_plus package
  final String verificationStatus;
  final List<String>? myCompaniesPortfolio;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.role,
    required this.address,
    this.idNumber,
    this.profileImage,
    this.selectedAvatar,
    required this.verificationStatus,
    this.myCompaniesPortfolio,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? role,
    String? address,
    String? idNumber,
    String? profileImage,
    String? selectedAvatar,
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
      idNumber: idNumber ?? this.idNumber,
      profileImage: profileImage ?? this.profileImage,
      selectedAvatar: selectedAvatar ?? this.selectedAvatar,
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
      'idNumber': idNumber,
      'profileImage': profileImage,
      'selectedAvatar': selectedAvatar,
      'verificationStatus': verificationStatus,
      'myCompaniesPortfolio': myCompaniesPortfolio,
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
      idNumber: map['idNumber']?.toString(),
      profileImage: map['profileImage']?.toString(),
      selectedAvatar: map['selectedAvatar']?.toString(),
      verificationStatus: map['verificationStatus']?.toString() ?? 'unverified',
      myCompaniesPortfolio: map['myCompaniesPortfolio'] != null ? List<String>.from(map['myCompaniesPortfolio']) : null,
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? ''),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? ''),
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
        other.idNumber == idNumber &&
        other.profileImage == profileImage &&
        other.selectedAvatar == selectedAvatar &&
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
        idNumber.hashCode ^
        profileImage.hashCode ^
        selectedAvatar.hashCode ^
        verificationStatus.hashCode;
  }
}