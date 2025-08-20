import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as appwrite_models;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/companies/model/rep_company_relation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final repCompanyRelationAPIProvider = Provider((ref) {
  // Note: This API is deprecated and will be replaced with FastAPI implementation
  return RepCompanyRelationAPI.stub();
});

abstract class IRepCompanyRelationAPI {
  FutureEither<appwrite_models.Document> addRelation(
      RepCompanyRelation relation);
}

class RepCompanyRelationAPI implements IRepCompanyRelationAPI {
  final Databases? _databases;
  RepCompanyRelationAPI({Databases? databases}) : _databases = databases;
  
  // Stub constructor for graceful degradation
  RepCompanyRelationAPI.stub() : _databases = null;

  @override
  FutureEither<appwrite_models.Document> addRelation(
      RepCompanyRelation relation) async {
    if (_databases == null) {
      return left(Failure('Rep-Company relation API not available during migration', StackTrace.current));
    }
    try {
      final document = await _databases!.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.repCompanyRelationCollectionId,
        documentId: ID.unique(),
        data: relation.toMap(),
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
