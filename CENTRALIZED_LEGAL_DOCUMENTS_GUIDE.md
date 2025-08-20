# Centralized Legal Documents System

## 📋 Overview

The legal documents system has been refactored from hardcoded content to a centralized, maintainable system that supports:

- **Centralized Storage**: All legal documents stored in JSON format
- **Version Control**: Document versioning and update tracking
- **User Acceptance Tracking**: Record and track user acceptance of documents
- **Automatic Updates**: Documents can be updated remotely without app updates
- **Caching**: Intelligent caching with fallback mechanisms
- **Search & Filtering**: Advanced document discovery capabilities

---

## 🏗️ **Architecture**

### **File Structure**
```
lib/features/legal/
├── model/
│   └── legal_document_model.dart          # Document and acceptance models
├── repository/
│   └── legal_document_repository.dart     # Data access layer
└── controller/
    └── legal_document_controller.dart     # Business logic and state management

assets/legal/
└── legal_documents.json                   # Centralized document storage

lib/features/profile/view/pages/
└── legal_terms_page_v2.dart              # New UI using centralized system
```

### **Data Flow**
```
Remote API → Local Cache → Assets → Fallback Documents
     ↓            ↓          ↓            ↓
User Interface ← Controller ← Repository ← Storage
```

---

## 📄 **Document Model**

### **LegalDocumentModel**
```dart
class LegalDocumentModel {
  final String id;              // Unique identifier
  final String title;           // Display title
  final String content;         // Full document content
  final String version;         // Version number (e.g., "1.2")
  final DateTime lastUpdated;   // Last update timestamp
  final String category;        // Document category
  final bool isRequired;        // Requires user acceptance
  final String? summary;        // Brief description
  final List<String> tags;      // Search tags
}
```

### **Document Categories**
- `terms_and_policies`: Terms of Service, User Agreement, etc.
- `rep_agreements`: Representative Agreement, Commission Structure, NDA
- `compliance`: GDPR Rights, Data Processing Consent
- `privacy`: Privacy Policy, Cookie Policy
- `general`: Other documents

### **User Acceptance Tracking**
```dart
class LegalDocumentAcceptance {
  final String documentId;      // Document being accepted
  final String userId;          // User accepting
  final String version;         // Version accepted
  final DateTime acceptedAt;    // Acceptance timestamp
  final String? ipAddress;      // Optional IP tracking
  final String? userAgent;      // Optional user agent
}
```

---

## 🔧 **Repository Layer**

### **Data Sources (Priority Order)**
1. **Remote API**: Fetch latest documents from server
2. **Local Cache**: SharedPreferences cache (24-hour expiry)
3. **Local Assets**: Bundled JSON file
4. **Fallback**: Hardcoded minimal documents

### **Key Methods**
```dart
// Get all documents
Future<List<LegalDocumentModel>> getAllDocuments()

// Get documents by category
Future<List<LegalDocumentModel>> getDocumentsByCategory(String category)

// Get specific document
Future<LegalDocumentModel?> getDocumentById(String id)

// Check user acceptance
Future<bool> hasUserAcceptedDocument(String userId, String documentId, String version)

// Record acceptance
Future<void> recordDocumentAcceptance(LegalDocumentAcceptance acceptance)

// Get user's acceptance history
Future<List<LegalDocumentAcceptance>> getUserAcceptanceHistory(String userId)

// Clear cache and refresh
Future<void> clearCache()
```

---

## 🎮 **Controller & State Management**

### **Riverpod Providers**
```dart
// Repository provider
final legalDocumentRepositoryProvider = Provider<LegalDocumentRepository>

// Controller provider
final legalDocumentControllerProvider = StateNotifierProvider<LegalDocumentController, LegalDocumentState>

// All documents provider
final allLegalDocumentsProvider = FutureProvider<List<LegalDocumentModel>>

// Documents by category
final legalDocumentsByCategoryProvider = FutureProvider.family<List<LegalDocumentModel>, String>

// Specific document
final legalDocumentByIdProvider = FutureProvider.family<LegalDocumentModel?, String>
```

### **Controller Features**
- **Document Loading**: Automatic loading with error handling
- **Search**: Full-text search across title, content, summary, and tags
- **Acceptance Management**: Track and record user acceptance
- **Update Detection**: Identify documents updated since user's last acceptance
- **Cache Management**: Refresh and clear cache functionality

---

## 📁 **JSON Document Format**

### **assets/legal/legal_documents.json**
```json
{
  "version": "1.0",
  "lastUpdated": "2024-01-15T00:00:00.000Z",
  "documents": [
    {
      "id": "terms_of_service",
      "title": "Terms of Service",
      "version": "1.2",
      "lastUpdated": 1705276800000,
      "category": "terms_and_policies",
      "isRequired": true,
      "summary": "Terms governing the use of FieldForce services",
      "tags": ["terms", "service", "legal"],
      "content": "FIELDFORCE TERMS OF SERVICE\n\n..."
    }
  ]
}
```

### **Document Properties**
- **id**: Unique identifier (snake_case)
- **title**: Human-readable title
- **version**: Semantic version (e.g., "1.2", "2.0")
- **lastUpdated**: Unix timestamp in milliseconds
- **category**: One of the predefined categories
- **isRequired**: Boolean indicating if user acceptance is required
- **summary**: Brief description for UI display
- **tags**: Array of searchable keywords
- **content**: Full document text with \n for line breaks

---

## 🎨 **User Interface**

### **LegalTermsPageV2 Features**
- **Search Bar**: Real-time document search
- **Category Grouping**: Documents organized by category
- **Document Status**: Visual indicators for required/accepted documents
- **Acceptance Tracking**: Shows acceptance status for each user
- **Refresh Capability**: Manual refresh from remote sources
- **Document Viewer**: Full-screen document display with acceptance workflow

### **Document Display**
- **Title & Version**: Clear document identification
- **Last Updated**: Timestamp display
- **Required Status**: Visual indicators for mandatory documents
- **Acceptance Status**: Check marks for accepted documents
- **Summary**: Brief description in subtitle

### **Document Dialog**
- **Full Content**: Scrollable document text
- **Version Info**: Document version and update date
- **Acceptance Workflow**: Accept button for required documents
- **Status Tracking**: Visual feedback for acceptance status

---

## 🔄 **Update Workflow**

### **Adding New Documents**
1. Add document to `assets/legal/legal_documents.json`
2. Increment version number
3. Update `lastUpdated` timestamp
4. Deploy app update or update remote API

### **Updating Existing Documents**
1. Modify document content in JSON
2. Increment version number (e.g., "1.0" → "1.1")
3. Update `lastUpdated` timestamp
4. Users will see update notifications

### **Remote Updates (Future)**
1. Update documents on server API
2. App automatically fetches updates
3. Cache is refreshed
4. Users see new content without app update

---

## 🧪 **Testing**

### **Test Coverage**
- **Model Serialization**: JSON serialization/deserialization
- **Repository Functions**: Document retrieval and caching
- **Acceptance Tracking**: User acceptance workflow
- **Category Filtering**: Document categorization
- **Search Functionality**: Document search and filtering

### **Test File**
`test/features/legal/legal_document_test.dart`

### **Key Test Cases**
- Document model serialization
- Repository fallback mechanisms
- User acceptance tracking
- Category filtering
- Document search
- Cache management

---

## 🚀 **Benefits of Centralized System**

### **Before (Hardcoded)**
```dart
void _showTermsOfService(BuildContext context) {
  _showLegalDocument(
    context,
    'Terms of Service',
    '''
    HARDCODED CONTENT HERE...
    ''',
  );
}
```

### **After (Centralized)**
```dart
// Documents loaded from JSON/API
final document = await repository.getDocumentById('terms_of_service');
_showDocument(context, document);

// Automatic acceptance tracking
await controller.acceptDocument(userId, documentId, version);
```

### **Advantages**
1. **Easy Updates**: Change JSON file instead of code
2. **Version Control**: Track document versions and user acceptance
3. **Remote Updates**: Update documents without app releases
4. **Compliance**: Proper acceptance tracking for legal requirements
5. **Search**: Find documents quickly with search functionality
6. **Caching**: Better performance with intelligent caching
7. **Fallback**: Graceful degradation when remote sources fail

---

## 📋 **Migration Guide**

### **From Old System**
1. **Replace Import**: Change from `legal_terms_page.dart` to `legal_terms_page_v2.dart`
2. **Update Navigation**: Use `LegalTermsPageV2()` instead of `LegalTermsPage()`
3. **Add Dependencies**: Ensure legal document providers are available
4. **Test Functionality**: Verify document loading and acceptance tracking

### **Backward Compatibility**
- Old legal terms page still exists for reference
- New system provides all functionality of old system
- Gradual migration possible

---

## 🔮 **Future Enhancements**

### **Planned Features**
1. **Remote API Integration**: Fetch documents from server
2. **Push Notifications**: Notify users of document updates
3. **Bulk Acceptance**: Accept multiple documents at once
4. **Document History**: View previous versions of documents
5. **Admin Panel**: Manage documents through web interface
6. **Analytics**: Track document engagement and acceptance rates
7. **Localization**: Multi-language document support
8. **Digital Signatures**: Enhanced acceptance with signatures

### **API Endpoints (Future)**
```
GET /api/legal/documents          # Get all documents
GET /api/legal/documents/:id      # Get specific document
POST /api/legal/acceptance        # Record user acceptance
GET /api/legal/user/:id/history   # Get user acceptance history
```

---

## 📞 **Support & Maintenance**

### **Document Updates**
- **Content Team**: Update document content in JSON
- **Legal Team**: Review and approve document changes
- **Dev Team**: Deploy updates and monitor system

### **Monitoring**
- **Document Load Times**: Monitor performance
- **Acceptance Rates**: Track user engagement
- **Error Rates**: Monitor failed document loads
- **Cache Hit Rates**: Optimize caching strategy

### **Troubleshooting**
- **Documents Not Loading**: Check network, cache, and fallback
- **Acceptance Not Recorded**: Verify SharedPreferences access
- **Search Not Working**: Check document indexing and tags
- **Version Conflicts**: Ensure proper version tracking

---

## 🎯 **Conclusion**

The centralized legal documents system provides a robust, maintainable solution for managing legal content in the FieldForce app. It supports:

- **Easy content updates** without code changes
- **Proper compliance tracking** with user acceptance records
- **Better user experience** with search and categorization
- **Future scalability** with remote API support

This system transforms legal document management from a maintenance burden into a streamlined, professional feature that supports business compliance and user experience goals.