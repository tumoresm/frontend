import 'package:fieldforce/model/company_model.dart';

abstract class ICompanyAPI {
  /// Fetches all companies where isActive is true.
  Future<List<Company>> getActiveCompanies({String? search, String? industry});

  /// Fetches a single company by its ID.
  Future<Company?> getCompanyById(String companyId);

  /// Adds a company to the rep's profile (repCompanyRelations collection).
  Future<void> addCompanyToRepProfile({
    required String userId,
    required String companyId,
    required DateTime dateAdded,
  });
}

// You will need to implement the Company model and the concrete API class for Appwrite.
