import 'dart:convert';

/// Model representing a legal document
class LegalDocumentModel {
  final String id;
  final String title;
  final String content;
  final String version;
  final DateTime lastUpdated;
  final String category;
  final bool isRequired;
  final String? summary;
  final List<String> tags;

  const LegalDocumentModel({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.lastUpdated,
    required this.category,
    this.isRequired = false,
    this.summary,
    this.tags = const [],
  });

  LegalDocumentModel copyWith({
    String? id,
    String? title,
    String? content,
    String? version,
    DateTime? lastUpdated,
    String? category,
    bool? isRequired,
    String? summary,
    List<String>? tags,
  }) {
    return LegalDocumentModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      version: version ?? this.version,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      category: category ?? this.category,
      isRequired: isRequired ?? this.isRequired,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'version': version,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
      'category': category,
      'isRequired': isRequired,
      'summary': summary,
      'tags': tags,
    };
  }

  factory LegalDocumentModel.fromMap(Map<String, dynamic> map) {
    return LegalDocumentModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      version: map['version'] ?? '1.0',
      lastUpdated: map['lastUpdated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'])
          : DateTime.now(),
      category: map['category'] ?? 'general',
      isRequired: map['isRequired'] ?? false,
      summary: map['summary'],
      tags: List<String>.from(map['tags'] ?? []),
    );
  }

  String toJson() => json.encode(toMap());

  factory LegalDocumentModel.fromJson(String source) =>
      LegalDocumentModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'LegalDocumentModel(id: $id, title: $title, version: $version, lastUpdated: $lastUpdated, category: $category, isRequired: $isRequired)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LegalDocumentModel &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.version == version &&
        other.lastUpdated == lastUpdated &&
        other.category == category &&
        other.isRequired == isRequired &&
        other.summary == summary;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        content.hashCode ^
        version.hashCode ^
        lastUpdated.hashCode ^
        category.hashCode ^
        isRequired.hashCode ^
        summary.hashCode;
  }
}

/// Categories for legal documents
class LegalDocumentCategory {
  static const String termsAndPolicies = 'terms_and_policies';
  static const String repAgreements = 'rep_agreements';
  static const String compliance = 'compliance';
  static const String privacy = 'privacy';
  static const String general = 'general';

  static const List<String> all = [
    termsAndPolicies,
    repAgreements,
    compliance,
    privacy,
    general,
  ];

  static String getDisplayName(String category) {
    switch (category) {
      case termsAndPolicies:
        return 'Terms & Policies';
      case repAgreements:
        return 'Rep Agreements';
      case compliance:
        return 'Compliance';
      case privacy:
        return 'Privacy';
      case general:
        return 'General';
      default:
        return 'Unknown';
    }
  }
}

/// User acceptance tracking for legal documents
class LegalDocumentAcceptance {
  final String documentId;
  final String userId;
  final String version;
  final DateTime acceptedAt;
  final String? ipAddress;
  final String? userAgent;

  const LegalDocumentAcceptance({
    required this.documentId,
    required this.userId,
    required this.version,
    required this.acceptedAt,
    this.ipAddress,
    this.userAgent,
  });

  Map<String, dynamic> toMap() {
    return {
      'documentId': documentId,
      'userId': userId,
      'version': version,
      'acceptedAt': acceptedAt.millisecondsSinceEpoch,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
    };
  }

  factory LegalDocumentAcceptance.fromMap(Map<String, dynamic> map) {
    return LegalDocumentAcceptance(
      documentId: map['documentId'] ?? '',
      userId: map['userId'] ?? '',
      version: map['version'] ?? '',
      acceptedAt: DateTime.fromMillisecondsSinceEpoch(map['acceptedAt']),
      ipAddress: map['ipAddress'],
      userAgent: map['userAgent'],
    );
  }

  String toJson() => json.encode(toMap());

  factory LegalDocumentAcceptance.fromJson(String source) =>
      LegalDocumentAcceptance.fromMap(json.decode(source));
}