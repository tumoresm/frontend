import 'package:fieldforce/features/legal/controller/legal_document_controller.dart';
import 'package:fieldforce/features/legal/model/legal_document_model.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class LegalTermsPageV2 extends ConsumerStatefulWidget {
  const LegalTermsPageV2({super.key});

  @override
  ConsumerState<LegalTermsPageV2> createState() => _LegalTermsPageV2State();
}

class _LegalTermsPageV2State extends ConsumerState<LegalTermsPageV2> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final legalState = ref.watch(legalDocumentControllerProvider);
    final currentUser = ref.watch(currentUserDetailsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Terms'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
        actions: [
          IconButton(
            icon: const Icon(Symbols.refresh),
            onPressed: () {
              ref.read(legalDocumentControllerProvider.notifier).refreshDocuments();
            },
            tooltip: 'Refresh Documents',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search legal documents...',
                prefixIcon: const Icon(Symbols.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),

          // Content
          Expanded(
            child: _buildContent(legalState, currentUser),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(LegalDocumentState legalState, AsyncValue currentUser) {
    if (legalState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (legalState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.error,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading legal documents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              legalState.error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(legalDocumentControllerProvider.notifier).loadDocuments();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final controller = ref.read(legalDocumentControllerProvider.notifier);
    final filteredDocuments = _searchQuery.isEmpty
        ? legalState.documents
        : controller.searchDocuments(_searchQuery);

    if (filteredDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Symbols.description_off,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'No legal documents available' : 'No documents found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Legal documents will appear here when available'
                  : 'Try different search terms',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Group documents by category
          ...LegalDocumentCategory.all.map((category) {
            final categoryDocs = filteredDocuments
                .where((doc) => doc.category == category)
                .toList();

            if (categoryDocs.isEmpty) return const SizedBox.shrink();

            return Column(
              children: [
                SettingsSection(
                  title: LegalDocumentCategory.getDisplayName(category),
                  icon: _getCategoryIcon(category),
                  children: categoryDocs.map((doc) {
                    return SettingsTile(
                      title: doc.title,
                      subtitle: _buildDocumentSubtitle(doc, currentUser),
                      icon: _getDocumentIcon(doc),
                      trailing: _buildDocumentTrailing(doc, currentUser),
                      onTap: () => _showDocument(context, doc, currentUser),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),

          // Document Information Card
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Symbols.info,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Document Information',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Legal documents are automatically updated and synchronized. '
                    'You will be notified when important documents require your attention.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Symbols.update,
                        size: 16,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Last updated: ${_formatDate(DateTime.now())}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case LegalDocumentCategory.termsAndPolicies:
        return Symbols.gavel;
      case LegalDocumentCategory.repAgreements:
        return Symbols.contract;
      case LegalDocumentCategory.compliance:
        return Symbols.verified_user;
      case LegalDocumentCategory.privacy:
        return Symbols.privacy_tip;
      default:
        return Symbols.description;
    }
  }

  IconData _getDocumentIcon(LegalDocumentModel doc) {
    if (doc.isRequired) {
      return Symbols.priority_high;
    }
    switch (doc.id) {
      case 'terms_of_service':
        return Symbols.description;
      case 'privacy_policy':
        return Symbols.privacy_tip;
      case 'user_agreement':
        return Symbols.handshake;
      case 'cookie_policy':
        return Symbols.cookie;
      case 'rep_agreement':
        return Symbols.assignment;
      case 'commission_structure':
        return Symbols.calculate;
      case 'nda':
        return Symbols.security;
      case 'gdpr_rights':
        return Symbols.shield;
      default:
        return Symbols.article;
    }
  }

  String _buildDocumentSubtitle(LegalDocumentModel doc, AsyncValue currentUser) {
    final parts = <String>[];
    
    if (doc.summary != null) {
      parts.add(doc.summary!);
    }
    
    parts.add('Version ${doc.version}');
    parts.add('Updated ${_formatDate(doc.lastUpdated)}');
    
    return parts.join(' • ');
  }

  Widget? _buildDocumentTrailing(LegalDocumentModel doc, AsyncValue currentUser) {
    if (!doc.isRequired) return null;

    return currentUser.when(
      data: (user) {
        if (user == null) return null;
        
        return FutureBuilder<bool>(
          future: ref
              .read(legalDocumentControllerProvider.notifier)
              .hasUserAcceptedDocument(user.id, doc.id, doc.version),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              );
            }
            
            final hasAccepted = snapshot.data ?? false;
            return Icon(
              hasAccepted ? Symbols.check_circle : Symbols.pending,
              color: hasAccepted ? Colors.green : Colors.orange,
              size: 20,
            );
          },
        );
      },
      loading: () => null,
      error: (_, __) => null,
    );
  }

  void _showDocument(BuildContext context, LegalDocumentModel doc, AsyncValue currentUser) {
    showDialog(
      context: context,
      builder: (context) => _DocumentDialog(
        document: doc,
        currentUser: currentUser,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _DocumentDialog extends ConsumerStatefulWidget {
  final LegalDocumentModel document;
  final AsyncValue currentUser;

  const _DocumentDialog({
    required this.document,
    required this.currentUser,
  });

  @override
  ConsumerState<_DocumentDialog> createState() => _DocumentDialogState();
}

class _DocumentDialogState extends ConsumerState<_DocumentDialog> {
  bool _hasAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkAcceptanceStatus();
  }

  Future<void> _checkAcceptanceStatus() async {
    final user = widget.currentUser.value;
    if (user != null) {
      final hasAccepted = await ref
          .read(legalDocumentControllerProvider.notifier)
          .hasUserAcceptedDocument(user.id, widget.document.id, widget.document.version);
      
      if (mounted) {
        setState(() {
          _hasAccepted = hasAccepted;
        });
      }
    }
  }

  Future<void> _acceptDocument() async {
    final user = widget.currentUser.value;
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(legalDocumentControllerProvider.notifier)
          .acceptDocument(user.id, widget.document.id, widget.document.version);
      
      if (mounted) {
        setState(() {
          _hasAccepted = true;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.document.title} accepted'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting document: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.document.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Version ${widget.document.version} • Updated ${_formatDate(widget.document.lastUpdated)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Symbols.close),
                ),
              ],
            ),
            
            if (widget.document.isRequired) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _hasAccepted ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _hasAccepted ? Colors.green : Colors.orange,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _hasAccepted ? Symbols.check_circle : Symbols.priority_high,
                      color: _hasAccepted ? Colors.green : Colors.orange,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _hasAccepted 
                            ? 'You have accepted this document'
                            : 'This document requires your acceptance',
                        style: TextStyle(
                          color: _hasAccepted ? Colors.green[700] : Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Divider(),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  widget.document.content,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                if (widget.document.isRequired && !_hasAccepted) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _acceptDocument,
                      child: _isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Accept'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}