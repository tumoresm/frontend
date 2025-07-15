class User {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String? profileImageUrl;
  final String verificationStatus;
  final String? idDocumentUrl;
  final String address;

  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    this.profileImageUrl,
    required this.verificationStatus,
    this.idDocumentUrl,
    required this.address,
  });
}
