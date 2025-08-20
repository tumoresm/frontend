import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final bankAccountAPIProvider = Provider((ref) {
  // Note: This API is deprecated and will be replaced with FastAPI implementation
  return BankAccountAPI.stub();
});

abstract class IBankAccountAPI {
  FutureEither<model.Document> createBankAccount(BankAccountModel bankAccount);
  FutureEither<model.Document> updateBankAccount(BankAccountModel bankAccount);
  FutureEither<bool> deleteBankAccount(String bankAccountId);
  Future<List<BankAccountModel>> getBankAccountsByUserId(String userId);
  Future<BankAccountModel?> getDefaultBankAccount(String userId);
  FutureEither<model.Document> setDefaultBankAccount({
    required String userId,
    required String bankAccountId,
  });
}

class BankAccountAPI implements IBankAccountAPI {
  final Databases? _db;
  BankAccountAPI({Databases? db}) : _db = db;

  // Stub constructor for graceful degradation
  BankAccountAPI.stub() : _db = null;

  @override
  FutureEither<model.Document> createBankAccount(
      BankAccountModel bankAccount) async {
    if (_db == null) {
      Loggers.database.warning('Bank account API not available during migration');
      return left(Failure('Bank account API not available during migration',
          StackTrace.current));
    }
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        documentId: ID.unique(),
        data: bankAccount.toMap(),
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
  FutureEither<model.Document> updateBankAccount(
      BankAccountModel bankAccount) async {
    if (_db == null) {
      return left(Failure('Bank account API not available during migration',
          StackTrace.current));
    }
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        documentId: bankAccount.id,
        data: bankAccount.toMap(),
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
  FutureEither<bool> deleteBankAccount(String bankAccountId) async {
    if (_db == null) {
      return left(Failure('Bank account API not available during migration',
          StackTrace.current));
    }
    try {
      await _db.deleteDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        documentId: bankAccountId,
      );
      return right(true);
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
  Future<List<BankAccountModel>> getBankAccountsByUserId(String userId) async {
    if (_db == null) {
      return [];
    }
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.orderDesc('createdAt'),
        ],
      );

      return documents.documents.map((doc) {
        final data = Map<String, dynamic>.from(doc.data);
        data['\$id'] = doc.$id; // Add document ID to data
        return BankAccountModel.fromMap(data);
      }).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<BankAccountModel?> getDefaultBankAccount(String userId) async {
    if (_db == null) {
      return null;
    }
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        queries: [
          Query.equal('userId', userId),
          Query.equal('isDefault', true),
        ],
      );

      if (documents.documents.isEmpty) {
        return null;
      }

      final doc = documents.documents.first;
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id; // Add document ID to data
      return BankAccountModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<model.Document> setDefaultBankAccount({
    required String userId,
    required String bankAccountId,
  }) async {
    if (_db == null) {
      return left(Failure('Bank account API not available during migration',
          StackTrace.current));
    }
    try {
      // First, unset all other accounts as default for this user
      final allAccounts = await getBankAccountsByUserId(userId);

      for (final account in allAccounts) {
        if (account.isDefault && account.id != bankAccountId) {
          final updatedAccount = account.copyWith(
            isDefault: false,
            updatedAt: DateTime.now(),
          );
          await _db.updateDocument(
            databaseId: AppwriteConstants.databaseId,
            collectionId: AppwriteConstants.bankAccountsCollection,
            documentId: account.id,
            data: updatedAccount.toMap(),
          );
        }
      }

      // Now set the specified account as default
      final targetAccount =
          allAccounts.firstWhere((account) => account.id == bankAccountId);
      final updatedTargetAccount = targetAccount.copyWith(
        isDefault: true,
        updatedAt: DateTime.now(),
      );

      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.bankAccountsCollection,
        documentId: bankAccountId,
        data: updatedTargetAccount.toMap(),
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
