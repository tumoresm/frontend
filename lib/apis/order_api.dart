import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as model;
import 'package:fieldforce/constants/appwrite_constants.dart';
import 'package:fieldforce/core/core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fieldforce/features/order/model/order_model.dart';
import 'package:fpdart/fpdart.dart';

final orderAPIProvider = Provider((ref) {
  return OrderAPI(
    db: ref.watch(appwriteDatabasesProvider),
  );
});

abstract class IOrderAPI {
  FutureEither<model.Document> createOrder(OrderModel order);
  Future<List<OrderModel>> getOrders();
  Future<List<OrderModel>> getRepOrders(String repId);
}

class OrderAPI implements IOrderAPI {
  final Databases _db;
  OrderAPI({required Databases db}) : _db = db;

  @override
  FutureEither<model.Document> createOrder(OrderModel order) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.ordersCollection,
        documentId: ID.unique(),
        data: order.toMap(),
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
  Future<List<OrderModel>> getOrders() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollection,
    );
    return documents.documents
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['\$id'] = doc.$id; // Add document ID to data
          return OrderModel.fromMap(data);
        })
        .toList();
  }

  @override
  Future<List<OrderModel>> getRepOrders(String repId) async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.ordersCollection,
      queries: [
        Query.equal('repId', repId),
      ],
    );
    return documents.documents
        .map((doc) {
          final data = Map<String, dynamic>.from(doc.data);
          data['\$id'] = doc.$id; // Add document ID to data
          return OrderModel.fromMap(data);
        })
        .toList();
  }
}
