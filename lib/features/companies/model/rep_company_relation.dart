// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

enum VerificationStatus { unverified, pending, verified, rejected }

class RepCompanyRelation {
  final String id;
  final String userId;
  final String companyId;
  final DateTime dateAdded;
  final VerificationStatus verificationStatus;

  RepCompanyRelation({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.dateAdded,
    required this.verificationStatus,
  });

  RepCompanyRelation copyWith({
    String? id,
    String? userId,
    String? companyId,
    DateTime? dateAdded,
    VerificationStatus? verificationStatus,
  }) =>
      RepCompanyRelation(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        companyId: companyId ?? this.companyId,
        dateAdded: dateAdded ?? this.dateAdded,
        verificationStatus: verificationStatus ?? this.verificationStatus,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'companyId': companyId,
        'dateAdded': dateAdded.toIso8601String(),
        'verificationStatus': verificationStatus.name,
      };

  factory RepCompanyRelation.fromMap(Map<String, dynamic> map) {
    return RepCompanyRelation(
      id: map['id'] as String,
      userId: map['userId'] as String,
      companyId: map['companyId'] as String,
      dateAdded: DateTime.parse(map['dateAdded'] as String),
      verificationStatus:
          VerificationStatus.values.byName(map['verificationStatus'] as String),
    );
  }

  String toJson() => json.encode(toMap());

  factory RepCompanyRelation.fromJson(String source) =>
      RepCompanyRelation.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'RepCompanyRelation(id: $id, userId: $userId, companyId: $companyId, dateAdded: $dateAdded, verificationStatus: $verificationStatus)';

  @override
  bool operator ==(covariant RepCompanyRelation other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.userId == userId &&
        other.companyId == companyId &&
        other.dateAdded == dateAdded &&
        other.verificationStatus == verificationStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        companyId.hashCode ^
        dateAdded.hashCode ^
        verificationStatus.hashCode;
  }
}
