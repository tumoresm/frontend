import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:fieldforce/features/legal/model/legal_document_model.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing legal documents
class LegalDocumentRepository {
  static const String _cacheKey = 'legal_documents_cache';
  static const String _lastUpdateKey = 'legal_documents_last_update';
  static const Duration _cacheExpiry = Duration(hours: 24);

  /// Get all legal documents
  Future<List<LegalDocumentModel>> getAllDocuments() async {
    try {
      // Try to get from cache first
      final cachedDocuments = await _getCachedDocuments();
      final isCacheExpired = await _isCacheExpired();
      if (cachedDocuments.isNotEmpty && !isCacheExpired) {
        Loggers.database.info('Loaded ${cachedDocuments.length} legal documents from cache');
        return cachedDocuments;
      }

      // Try to fetch from remote API
      final remoteDocuments = await _fetchFromRemote();
      if (remoteDocuments.isNotEmpty) {
        await _cacheDocuments(remoteDocuments);
        Loggers.database.info('Loaded ${remoteDocuments.length} legal documents from remote');
        return remoteDocuments;
      }

      // Fallback to local assets
      final localDocuments = await _loadFromAssets();
      Loggers.database.info('Loaded ${localDocuments.length} legal documents from assets');
      return localDocuments;
    } catch (e) {
      Loggers.database.error('Error loading legal documents: $e');
      // Return fallback documents
      return _getFallbackDocuments();
    }
  }

  /// Get documents by category
  Future<List<LegalDocumentModel>> getDocumentsByCategory(String category) async {
    final allDocuments = await getAllDocuments();
    return allDocuments.where((doc) => doc.category == category).toList();
  }

  /// Get a specific document by ID
  Future<LegalDocumentModel?> getDocumentById(String id) async {
    final allDocuments = await getAllDocuments();
    try {
      return allDocuments.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Check if user has accepted a document version
  Future<bool> hasUserAcceptedDocument(String userId, String documentId, String version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final acceptanceKey = 'acceptance_${userId}_${documentId}_$version';
      return prefs.getBool(acceptanceKey) ?? false;
    } catch (e) {
      Loggers.database.error('Error checking document acceptance: $e');
      return false;
    }
  }

  /// Record user acceptance of a document
  Future<void> recordDocumentAcceptance(LegalDocumentAcceptance acceptance) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final acceptanceKey = 'acceptance_${acceptance.userId}_${acceptance.documentId}_${acceptance.version}';
      await prefs.setBool(acceptanceKey, true);
      await prefs.setString('${acceptanceKey}_date', acceptance.acceptedAt.toIso8601String());
      
      Loggers.database.info('Recorded acceptance for document ${acceptance.documentId} by user ${acceptance.userId}');
    } catch (e) {
      Loggers.database.error('Error recording document acceptance: $e');
    }
  }

  /// Get user's acceptance history
  Future<List<LegalDocumentAcceptance>> getUserAcceptanceHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith('acceptance_$userId')).toList();
      
      final acceptances = <LegalDocumentAcceptance>[];
      for (final key in keys) {
        if (key.endsWith('_date')) continue; // Skip date keys
        
        final parts = key.split('_');
        if (parts.length >= 4) {
          final documentId = parts[2];
          final version = parts[3];
          final dateKey = '${key}_date';
          final dateString = prefs.getString(dateKey);
          
          if (dateString != null) {
            acceptances.add(LegalDocumentAcceptance(
              documentId: documentId,
              userId: userId,
              version: version,
              acceptedAt: DateTime.parse(dateString),
            ));
          }
        }
      }
      
      return acceptances;
    } catch (e) {
      Loggers.database.error('Error getting user acceptance history: $e');
      return [];
    }
  }

  /// Clear cache and force refresh
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_cacheKey);
      await prefs.remove(_lastUpdateKey);
      Loggers.database.info('Legal documents cache cleared');
    } catch (e) {
      Loggers.database.error('Error clearing cache: $e');
    }
  }

  /// Private methods

  Future<List<LegalDocumentModel>> _getCachedDocuments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null) {
        final List<dynamic> jsonList = json.decode(cachedJson);
        return jsonList.map((json) => LegalDocumentModel.fromMap(json)).toList();
      }
    } catch (e) {
      Loggers.database.error('Error loading cached documents: $e');
    }
    return [];
  }

  Future<bool> _isCacheExpired() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getInt(_lastUpdateKey);
      if (lastUpdate != null) {
        final lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdate);
        return DateTime.now().difference(lastUpdateTime) > _cacheExpiry;
      }
    } catch (e) {
      Loggers.database.error('Error checking cache expiry: $e');
    }
    return true;
  }

  Future<void> _cacheDocuments(List<LegalDocumentModel> documents) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = documents.map((doc) => doc.toMap()).toList();
      await prefs.setString(_cacheKey, json.encode(jsonList));
      await prefs.setInt(_lastUpdateKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      Loggers.database.error('Error caching documents: $e');
    }
  }

  Future<List<LegalDocumentModel>> _fetchFromRemote() async {
    try {
      // TODO: Replace with actual API endpoint
      final response = await http.get(
        Uri.parse('https://api.fieldforce.com/legal/documents'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> documentsJson = data['documents'] ?? [];
        return documentsJson.map((json) => LegalDocumentModel.fromMap(json)).toList();
      }
    } catch (e) {
      Loggers.database.warning('Could not fetch legal documents from remote: $e');
    }
    return [];
  }

  Future<List<LegalDocumentModel>> _loadFromAssets() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/legal/legal_documents.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> documentsJson = data['documents'] ?? [];
      return documentsJson.map((json) => LegalDocumentModel.fromMap(json)).toList();
    } catch (e) {
      Loggers.database.warning('Could not load legal documents from assets: $e');
      return _getFallbackDocuments();
    }
  }

  List<LegalDocumentModel> _getFallbackDocuments() {
    final now = DateTime.now();
    return [
      LegalDocumentModel(
        id: 'terms_of_service',
        title: 'Terms of Service',
        content: 'Terms of Service content will be loaded from the server.',
        version: '1.0',
        lastUpdated: now,
        category: LegalDocumentCategory.termsAndPolicies,
        isRequired: true,
        summary: 'Terms governing the use of FieldForce services',
        tags: ['terms', 'service', 'legal'],
      ),
      LegalDocumentModel(
        id: 'privacy_policy',
        title: 'Privacy Policy',
        content: 'Privacy Policy content will be loaded from the server.',
        version: '1.0',
        lastUpdated: now,
        category: LegalDocumentCategory.privacy,
        isRequired: true,
        summary: 'How we collect, use, and protect your personal information',
        tags: ['privacy', 'data', 'protection'],
      ),
      LegalDocumentModel(
        id: 'user_agreement',
        title: 'User Agreement',
        content: 'User Agreement content will be loaded from the server.',
        version: '1.0',
        lastUpdated: now,
        category: LegalDocumentCategory.termsAndPolicies,
        isRequired: true,
        summary: 'Agreement between users and FieldForce',
        tags: ['agreement', 'user', 'contract'],
      ),
      LegalDocumentModel(
        id: 'rep_agreement',
        title: 'Representative Agreement',
        content: 'Representative Agreement content will be loaded from the server.',
        version: '1.0',
        lastUpdated: now,
        category: LegalDocumentCategory.repAgreements,
        isRequired: true,
        summary: 'Terms for field sales representatives',
        tags: ['representative', 'sales', 'commission'],
      ),
    ];
  }
}