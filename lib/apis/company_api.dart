import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final companyAPIProvider = Provider((ref) {
  // Note: This API is deprecated and will be replaced with FastAPI implementation
  // For now, return a stub implementation that provides graceful degradation
  return CompanyAPI.stub();
});

abstract class ICompanyAPI {
  Future<Either<Failure, List<appwrite_models.Document>>> getCompanies();
  Future<Either<Failure, appwrite_models.Document>> getCompanyById(String id);
}

class CompanyAPI implements ICompanyAPI {
  final Databases? _databases;
  CompanyAPI({Databases? databases}) : _databases = databases;
  
  // Stub constructor for graceful degradation
  CompanyAPI.stub() : _databases = null;

  @override
  Future<Either<Failure, List<appwrite_models.Document>>> getCompanies() async {
    if (_databases == null) {
      Loggers.database.warning('Company API not available during migration');
      return left(Failure('Company API not available during migration', StackTrace.current));
    }
    try {
      final documents = await _databases!.listDocuments(
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
    if (_databases == null) {
      Loggers.database.warning('Company API not available during migration');
      return left(Failure('Company API not available during migration', StackTrace.current));
    }
    try {
      final document = await _databases!.getDocument(
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
