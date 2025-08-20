import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final transactionAPIProvider = Provider((ref) {
  // Note: This API is deprecated and will be replaced with FastAPI implementation
  return TransactionAPI.stub();
});

abstract class ITransactionAPI {
  FutureEither<model.Document> createTransaction(TransactionModel transaction);
  Future<List<TransactionModel>> getTransactionsByUserId(String userId);
  Future<List<TransactionModel>> getTransactionsByWalletId(String walletId);
  Future<List<TransactionModel>> getTransactionsByType({
    required String userId,
    required TransactionType type,
  });
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}

class TransactionAPI implements ITransactionAPI {
  final Databases? _db;
  TransactionAPI({Databases? db}) : _db = db;
  
  // Stub constructor for graceful degradation
  TransactionAPI.stub() : _db = null;

  @override
  FutureEither<model.Document> createTransaction(TransactionModel transaction) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.transactionsCollection,
        documentId: ID.unique(),
        data: transaction.toMap(),
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
  Future<List<TransactionModel>> getTransactionsByUserId(String userId) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.transactionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id; // Add document ID to data
            return TransactionModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByWalletId(String walletId) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.transactionsCollection,
        queries: [
          Query.equal('walletId', walletId),
          Query.orderDesc('createdAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id; // Add document ID to data
            return TransactionModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByType({
    required String userId,
    required TransactionType type,
  }) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.transactionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('type', type.value),
          Query.orderDesc('createdAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id; // Add document ID to data
            return TransactionModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.transactionsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.greaterThanEqual('createdAt', startDate.millisecondsSinceEpoch),
          Query.lessThanEqual('createdAt', endDate.millisecondsSinceEpoch),
          Query.orderDesc('createdAt'),
        ],
      );
      
      return documents.documents
          .map((doc) {
            final data = Map<String, dynamic>.from(doc.data);
            data['\$id'] = doc.$id; // Add document ID to data
            return TransactionModel.fromMap(data);
          })
          .toList();
    } catch (e) {
      return [];
    }
  }
}