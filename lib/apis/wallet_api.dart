import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:fieldforce/features/wallet/model/wallet_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final walletAPIProvider = Provider((ref) {
  return WalletAPI(
    db: ref.watch(appwriteDatabasesProvider),
  );
});

abstract class IWalletAPI {
  FutureEither<model.Document> createWallet(WalletModel wallet);
  FutureEither<model.Document> updateWallet(WalletModel wallet);
  Future<WalletModel?> getWalletByUserId(String userId);
  FutureEither<model.Document> updateBalance({
    required String walletId,
    required double amount,
    required String type, // 'add' or 'subtract'
  });
}

class WalletAPI implements IWalletAPI {
  final Databases _db;
  WalletAPI({required Databases db}) : _db = db;

  @override
  FutureEither<model.Document> createWallet(WalletModel wallet) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.walletsCollection,
        documentId: ID.unique(),
        data: wallet.toMap(),
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
  FutureEither<model.Document> updateWallet(WalletModel wallet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.walletsCollection,
        documentId: wallet.id,
        data: wallet.toMap(),
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
  Future<WalletModel?> getWalletByUserId(String userId) async {
    try {
      final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.walletsCollection,
        queries: [
          Query.equal('userId', userId),
        ],
      );
      
      if (documents.documents.isEmpty) {
        return null;
      }
      
      final doc = documents.documents.first;
      final data = Map<String, dynamic>.from(doc.data);
      data['\$id'] = doc.$id; // Add document ID to data
      return WalletModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither<model.Document> updateBalance({
    required String walletId,
    required double amount,
    required String type,
  }) async {
    try {
      // First get the current wallet
      final currentDoc = await _db.getDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.walletsCollection,
        documentId: walletId,
      );
      
      final currentData = Map<String, dynamic>.from(currentDoc.data);
      currentData['\$id'] = currentDoc.$id;
      final currentWallet = WalletModel.fromMap(currentData);
      
      // Calculate new balance
      double newBalance;
      if (type == 'add') {
        newBalance = currentWallet.currentBalance + amount;
      } else if (type == 'subtract') {
        newBalance = currentWallet.currentBalance - amount;
      } else {
        return left(Failure('Invalid balance update type: $type', StackTrace.current));
      }
      
      // Update the wallet with new balance and timestamp
      final updatedWallet = currentWallet.copyWith(
        currentBalance: newBalance,
        lastUpdated: DateTime.now(),
      );
      
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.walletsCollection,
        documentId: walletId,
        data: updatedWallet.toMap(),
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