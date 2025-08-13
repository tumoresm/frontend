/// Constants for verification status values that match Appwrite enum constraints
class VerificationStatus {
  static const String unverified = 'Unverified';
  static const String pending = 'Pending';
  static const String verified = 'Verified';
  static const String rejected = 'Rejected';
  
  /// List of all valid verification statuses
  static const List<String> allStatuses = [
    unverified,
    pending,
    verified,
    rejected,
  ];
  
  /// Check if a status is valid
  static bool isValid(String status) {
    return allStatuses.contains(status);
  }
}