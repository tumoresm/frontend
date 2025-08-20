import 'package:flutter_test/flutter_test.dart';
import 'package:fieldforce/features/legal/model/legal_document_model.dart';
import 'package:fieldforce/features/legal/repository/legal_document_repository.dart';

void main() {
  group('Legal Document System Tests', () {
    late LegalDocumentRepository repository;

    setUp(() {
      repository = LegalDocumentRepository();
    });

    test('LegalDocumentModel serialization works correctly', () {
      final document = LegalDocumentModel(
        id: 'test_doc',
        title: 'Test Document',
        content: 'This is a test document content.',
        version: '1.0',
        lastUpdated: DateTime(2024, 1, 15),
        category: LegalDocumentCategory.termsAndPolicies,
        isRequired: true,
        summary: 'A test document for testing purposes',
        tags: ['test', 'document'],
      );

      // Test toJson and fromJson
      final json = document.toJson();
      final restored = LegalDocumentModel.fromJson(json);

      expect(restored.id, equals(document.id));
      expect(restored.title, equals(document.title));
      expect(restored.content, equals(document.content));
      expect(restored.version, equals(document.version));
      expect(restored.category, equals(document.category));
      expect(restored.isRequired, equals(document.isRequired));
      expect(restored.summary, equals(document.summary));
      expect(restored.tags, equals(document.tags));
    });

    test('LegalDocumentAcceptance serialization works correctly', () {
      final acceptance = LegalDocumentAcceptance(
        documentId: 'test_doc',
        userId: 'user123',
        version: '1.0',
        acceptedAt: DateTime(2024, 1, 15, 10, 30),
        ipAddress: '192.168.1.1',
        userAgent: 'Test User Agent',
      );

      // Test toJson and fromJson
      final json = acceptance.toJson();
      final restored = LegalDocumentAcceptance.fromJson(json);

      expect(restored.documentId, equals(acceptance.documentId));
      expect(restored.userId, equals(acceptance.userId));
      expect(restored.version, equals(acceptance.version));
      expect(restored.acceptedAt, equals(acceptance.acceptedAt));
      expect(restored.ipAddress, equals(acceptance.ipAddress));
      expect(restored.userAgent, equals(acceptance.userAgent));
    });

    test('LegalDocumentCategory provides correct display names', () {
      expect(
        LegalDocumentCategory.getDisplayName(LegalDocumentCategory.termsAndPolicies),
        equals('Terms & Policies'),
      );
      expect(
        LegalDocumentCategory.getDisplayName(LegalDocumentCategory.repAgreements),
        equals('Rep Agreements'),
      );
      expect(
        LegalDocumentCategory.getDisplayName(LegalDocumentCategory.compliance),
        equals('Compliance'),
      );
      expect(
        LegalDocumentCategory.getDisplayName(LegalDocumentCategory.privacy),
        equals('Privacy'),
      );
      expect(
        LegalDocumentCategory.getDisplayName('unknown'),
        equals('Unknown'),
      );
    });

    test('Repository returns fallback documents when assets fail', () async {
      // This test will use fallback documents since assets won't be available in test environment
      final documents = await repository.getAllDocuments();
      
      expect(documents, isNotEmpty);
      expect(documents.length, greaterThanOrEqualTo(4)); // At least the fallback documents
      
      // Check that required documents are present
      final termsDoc = documents.where((doc) => doc.id == 'terms_of_service').firstOrNull;
      expect(termsDoc, isNotNull);
      expect(termsDoc!.isRequired, isTrue);
      
      final privacyDoc = documents.where((doc) => doc.id == 'privacy_policy').firstOrNull;
      expect(privacyDoc, isNotNull);
      expect(privacyDoc!.isRequired, isTrue);
    });

    test('Repository can filter documents by category', () async {
      final allDocuments = await repository.getAllDocuments();
      final termsAndPolicies = await repository.getDocumentsByCategory(
        LegalDocumentCategory.termsAndPolicies,
      );
      
      expect(termsAndPolicies, isNotEmpty);
      
      // All returned documents should be in the correct category
      for (final doc in termsAndPolicies) {
        expect(doc.category, equals(LegalDocumentCategory.termsAndPolicies));
      }
      
      // Should be a subset of all documents
      expect(termsAndPolicies.length, lessThanOrEqualTo(allDocuments.length));
    });

    test('Repository can get document by ID', () async {
      final document = await repository.getDocumentById('terms_of_service');
      
      expect(document, isNotNull);
      expect(document!.id, equals('terms_of_service'));
      expect(document.title, equals('Terms of Service'));
    });

    test('Repository returns null for non-existent document', () async {
      final document = await repository.getDocumentById('non_existent_doc');
      expect(document, isNull);
    });

    test('User acceptance tracking works correctly', () async {
      const userId = 'test_user_123';
      const documentId = 'terms_of_service';
      const version = '1.0';
      
      // Initially, user should not have accepted the document
      final initialAcceptance = await repository.hasUserAcceptedDocument(
        userId,
        documentId,
        version,
      );
      expect(initialAcceptance, isFalse);
      
      // Record acceptance
      final acceptance = LegalDocumentAcceptance(
        documentId: documentId,
        userId: userId,
        version: version,
        acceptedAt: DateTime.now(),
      );
      
      await repository.recordDocumentAcceptance(acceptance);
      
      // Now user should have accepted the document
      final afterAcceptance = await repository.hasUserAcceptedDocument(
        userId,
        documentId,
        version,
      );
      expect(afterAcceptance, isTrue);
      
      // Check acceptance history
      final history = await repository.getUserAcceptanceHistory(userId);
      expect(history, isNotEmpty);
      
      final userAcceptance = history.where((a) => a.documentId == documentId).firstOrNull;
      expect(userAcceptance, isNotNull);
      expect(userAcceptance!.userId, equals(userId));
      expect(userAcceptance.version, equals(version));
    });

    test('Cache clearing works correctly', () async {
      // This test ensures cache clearing doesn't throw errors
      await repository.clearCache();
      
      // Should still be able to get documents after cache clear
      final documents = await repository.getAllDocuments();
      expect(documents, isNotEmpty);
    });
  });
}