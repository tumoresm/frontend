import 'package:fieldforce/features/legal/model/legal_document_model.dart';
import 'package:fieldforce/features/legal/repository/legal_document_repository.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for legal document repository
final legalDocumentRepositoryProvider = Provider<LegalDocumentRepository>((ref) {
  return LegalDocumentRepository();
});

/// Provider for legal document controller
final legalDocumentControllerProvider = StateNotifierProvider<LegalDocumentController, LegalDocumentState>((ref) {
  return LegalDocumentController(ref.read(legalDocumentRepositoryProvider));
});

/// Provider for all legal documents
final allLegalDocumentsProvider = FutureProvider<List<LegalDocumentModel>>((ref) async {
  final repository = ref.read(legalDocumentRepositoryProvider);
  return repository.getAllDocuments();
});

/// Provider for documents by category
final legalDocumentsByCategoryProvider = FutureProvider.family<List<LegalDocumentModel>, String>((ref, category) async {
  final repository = ref.read(legalDocumentRepositoryProvider);
  return repository.getDocumentsByCategory(category);
});

/// Provider for a specific document
final legalDocumentByIdProvider = FutureProvider.family<LegalDocumentModel?, String>((ref, id) async {
  final repository = ref.read(legalDocumentRepositoryProvider);
  return repository.getDocumentById(id);
});

/// State for legal document management
class LegalDocumentState {
  final List<LegalDocumentModel> documents;
  final bool isLoading;
  final String? error;
  final Map<String, bool> acceptanceStatus;

  const LegalDocumentState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.acceptanceStatus = const {},
  });

  LegalDocumentState copyWith({
    List<LegalDocumentModel>? documents,
    bool? isLoading,
    String? error,
    Map<String, bool>? acceptanceStatus,
  }) {
    return LegalDocumentState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      acceptanceStatus: acceptanceStatus ?? this.acceptanceStatus,
    );
  }
}

/// Controller for managing legal documents
class LegalDocumentController extends StateNotifier<LegalDocumentState> {
  final LegalDocumentRepository _repository;

  LegalDocumentController(this._repository) : super(const LegalDocumentState()) {
    loadDocuments();
  }

  /// Load all legal documents
  Future<void> loadDocuments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final documents = await _repository.getAllDocuments();
      
      state = state.copyWith(
        documents: documents,
        isLoading: false,
        error: null,
      );
      
      Loggers.database.info('Loaded ${documents.length} legal documents');
    } catch (e) {
      Loggers.database.error('Error loading legal documents: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load legal documents: $e',
      );
    }
  }

  /// Get documents by category
  List<LegalDocumentModel> getDocumentsByCategory(String category) {
    return state.documents.where((doc) => doc.category == category).toList();
  }

  /// Get a specific document by ID
  LegalDocumentModel? getDocumentById(String id) {
    try {
      return state.documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has accepted a document
  Future<bool> hasUserAcceptedDocument(String userId, String documentId, String version) async {
    try {
      return await _repository.hasUserAcceptedDocument(userId, documentId, version);
    } catch (e) {
      Loggers.database.error('Error checking document acceptance: $e');
      return false;
    }
  }

  /// Record user acceptance of a document
  Future<void> acceptDocument(String userId, String documentId, String version) async {
    try {
      final acceptance = LegalDocumentAcceptance(
        documentId: documentId,
        userId: userId,
        version: version,
        acceptedAt: DateTime.now(),
      );
      
      await _repository.recordDocumentAcceptance(acceptance);
      
      // Update local state
      final updatedAcceptance = Map<String, bool>.from(state.acceptanceStatus);
      updatedAcceptance['${userId}_${documentId}_$version'] = true;
      
      state = state.copyWith(acceptanceStatus: updatedAcceptance);
      
      Loggers.database.info('User $userId accepted document $documentId version $version');
    } catch (e) {
      Loggers.database.error('Error accepting document: $e');
      throw Exception('Failed to record document acceptance');
    }
  }

  /// Get user's acceptance history
  Future<List<LegalDocumentAcceptance>> getUserAcceptanceHistory(String userId) async {
    try {
      return await _repository.getUserAcceptanceHistory(userId);
    } catch (e) {
      Loggers.database.error('Error getting acceptance history: $e');
      return [];
    }
  }

  /// Get required documents that user hasn't accepted
  Future<List<LegalDocumentModel>> getRequiredUnacceptedDocuments(String userId) async {
    try {
      final requiredDocs = state.documents.where((doc) => doc.isRequired).toList();
      final unacceptedDocs = <LegalDocumentModel>[];
      
      for (final doc in requiredDocs) {
        final hasAccepted = await hasUserAcceptedDocument(userId, doc.id, doc.version);
        if (!hasAccepted) {
          unacceptedDocs.add(doc);
        }
      }
      
      return unacceptedDocs;
    } catch (e) {
      Loggers.database.error('Error getting unaccepted documents: $e');
      return [];
    }
  }

  /// Refresh documents from remote source
  Future<void> refreshDocuments() async {
    try {
      await _repository.clearCache();
      await loadDocuments();
      Loggers.database.info('Legal documents refreshed');
    } catch (e) {
      Loggers.database.error('Error refreshing documents: $e');
      state = state.copyWith(error: 'Failed to refresh documents: $e');
    }
  }

  /// Search documents by title or content
  List<LegalDocumentModel> searchDocuments(String query) {
    if (query.isEmpty) return state.documents;
    
    final lowercaseQuery = query.toLowerCase();
    return state.documents.where((doc) {
      return doc.title.toLowerCase().contains(lowercaseQuery) ||
             doc.content.toLowerCase().contains(lowercaseQuery) ||
             doc.summary?.toLowerCase().contains(lowercaseQuery) == true ||
             doc.tags.any((tag) => tag.toLowerCase().contains(lowercaseQuery));
    }).toList();
  }

  /// Get documents that have been updated since user's last acceptance
  Future<List<LegalDocumentModel>> getUpdatedDocuments(String userId) async {
    try {
      final acceptanceHistory = await getUserAcceptanceHistory(userId);
      final updatedDocs = <LegalDocumentModel>[];
      
      for (final doc in state.documents) {
        final userAcceptance = acceptanceHistory
            .where((acceptance) => acceptance.documentId == doc.id)
            .toList();
        
        if (userAcceptance.isEmpty) {
          // User has never accepted this document
          updatedDocs.add(doc);
        } else {
          // Check if document has been updated since last acceptance
          final latestAcceptance = userAcceptance
              .reduce((a, b) => a.acceptedAt.isAfter(b.acceptedAt) ? a : b);
          
          if (doc.lastUpdated.isAfter(latestAcceptance.acceptedAt)) {
            updatedDocs.add(doc);
          }
        }
      }
      
      return updatedDocs;
    } catch (e) {
      Loggers.database.error('Error getting updated documents: $e');
      return [];
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }
}