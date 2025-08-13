import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final withdrawalRequestAPIProvider = Provider((ref) {
  return WithdrawalRequestAPI(
    db: ref.watch(appwriteDatabasesProvider),
  );
});

abstract class IWithdrawalRequestAPI {
  FutureEither<model.Document> createWithdrawalRequest(WithdrawalRequestModel request);
  FutureEither<model.Document> updateWithdrawalRequest(WithdrawalRequestModel request);
  Future<List<WithdrawalRequestModel>> getWithdrawalRequestsByUserId(String userId);
  Future<List<WithdrawalRequestModel>> getWithdrawalRequestsByStatus(WithdrawalStatus status);
  FutureEither<model.Document> cancelWithdrawalRequest(String requestId);
}

class WithdrawalRequestAPI implements IWithdrawalRequestAPI {
  final Databases _db;
  WithdrawalRequestAPI({required Databases db}) : _db = db;

  @override
  FutureEither<model.Document> createWithdrawalRequest(WithdrawalRequestModel request) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        documentId: ID.unique(),
        data: request.toMap(),
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

  @override
  FutureEither<model.Document> updateWithdrawalRequest(WithdrawalRequestModel request) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        documentId: request.id,
        data: request.toMap(),
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

  @override
  Future<List<WithdrawalRequestModel>> getWithdrawalRequestsByUserId(String userId) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('requestedAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id;
            return WithdrawalRequestModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<WithdrawalRequestModel>> getWithdrawalRequestsByStatus(WithdrawalStatus status) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        queries: [
          Query.equal('status', status.value),
          Query.orderDesc('requestedAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id;
            return WithdrawalRequestModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  FutureEither<model.Document> cancelWithdrawalRequest(String requestId) async {
    try {
      final currentDoc = await _db.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        documentId: requestId,
      );
      
      final currentData = Map<String, dynamic>.from(currentDoc.data);
      currentData['\$id'] = currentDoc.$id;
      final currentRequest = WithdrawalRequestModel.fromMap(currentData);
      
      if (!currentRequest.canBeCancelled) {
        return left(Failure('This withdrawal request cannot be cancelled', StackTrace.current));
      }
      
      final updatedRequest = currentRequest.copyWith(
        status: WithdrawalStatus.cancelled,
        processedAt: DateTime.now(),
        notes: 'Cancelled by user',
      );
      
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.withdrawalRequestsCollection,
        documentId: requestId,
        data: updatedRequest.toMap(),
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