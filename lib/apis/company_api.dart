import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final companyAPIProvider = Provider((ref) {
  return CompanyAPI(
    databases: ref.watch(appwriteDatabasesProvider),
  );
});

abstract class ICompanyAPI {
  Future<Either<Failure, List<appwrite_models.Document>>> getCompanies();
  Future<Either<Failure, appwrite_models.Document>> getCompanyById(String id);
}

class CompanyAPI implements ICompanyAPI {
  final Databases _databases;
  CompanyAPI({required Databases databases}) : _databases = databases;

  @override
  Future<Either<Failure, List<appwrite_models.Document>>> getCompanies() async {
    try {
      final documents = await _databases.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.companyCollection,
      );
      return right(documents.documents);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<Either<Failure, appwrite_models.Document>> getCompanyById(
      String id) async {
    try {
      final document = await _databases.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.companyCollection,
        documentId: id,
      );
      return right(document);
    } on AppwriteException catch (e, st) {
      return left(
        Failure(
          e.message ?? 'Some unexpected error occurred',
          st,
        ),
      );
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }
}
