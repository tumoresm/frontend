import 'package:fieldforce/apis/industry_api.dart';
import 'package:fieldforce/features/company/model/industry_model.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/providers/company_provider.dart';
import 'package:fieldforce/core/logger.dart';
import 'package:fieldforce/utils/error_page.dart';
import 'package:fieldforce/utils/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getIndustriesProvider = FutureProvider<List<IndustryModel>>((ref) async {
  try {
    final industryAPI = ref.watch(industryAPIProvider);
    final res = await industryAPI.getIndustries();
    return res.fold(
      (l) {
        Loggers.database.warning('Failed to get industries: ${l.message}');
        // Return default industries as fallback
        return _getDefaultIndustries();
      },
      (r) {
        if (r.isEmpty) {
          Loggers.database.info('No industries returned from API, using defaults');
          return _getDefaultIndustries();
        }
        Loggers.database.info('Successfully loaded ${r.length} industries');
        return r;
      },
    );
  } catch (e) {
    Loggers.database.error('Error in getIndustriesProvider: $e');
    // Return default industries as fallback
    return _getDefaultIndustries();
  }
}, name: 'getIndustriesProvider');

/// Fallback industries when API is not available
List<IndustryModel> _getDefaultIndustries() {
  return [
    const IndustryModel(id: 'tech', name: 'Technology'),
    const IndustryModel(id: 'finance', name: 'Finance & Banking'),
    const IndustryModel(id: 'healthcare', name: 'Healthcare'),
    const IndustryModel(id: 'retail', name: 'Retail & E-commerce'),
    const IndustryModel(id: 'manufacturing', name: 'Manufacturing'),
    const IndustryModel(id: 'education', name: 'Education'),
    const IndustryModel(id: 'real_estate', name: 'Real Estate'),
    const IndustryModel(id: 'automotive', name: 'Automotive'),
    const IndustryModel(id: 'food_beverage', name: 'Food & Beverage'),
    const IndustryModel(id: 'telecommunications', name: 'Telecommunications'),
    const IndustryModel(id: 'energy', name: 'Energy & Utilities'),
    const IndustryModel(id: 'consulting', name: 'Consulting'),
    const IndustryModel(id: 'media', name: 'Media & Entertainment'),
    const IndustryModel(id: 'agriculture', name: 'Agriculture'),
    const IndustryModel(id: 'construction', name: 'Construction'),
    const IndustryModel(id: 'logistics', name: 'Logistics & Transportation'),
    const IndustryModel(id: 'tourism', name: 'Tourism & Hospitality'),
    const IndustryModel(id: 'other', name: 'Other'),
  ];
}

class AddCompanyPage extends ConsumerStatefulWidget {
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => const AddCompanyPage(),
      );
  const AddCompanyPage({super.key});

  @override
  ConsumerState<AddCompanyPage> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends ConsumerState<AddCompanyPage> {
  String _search = '';
  String? _selectedIndustryId;
  IndustryModel? _selectedIndustry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Company'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Field
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Search companies',
                    hintText: 'Enter company name...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  onChanged: (value) {
                    setState(() => _search = value);
                  },
                ),
                const SizedBox(height: 16),
                // Industry Filter
                _buildIndustryFilter(),
              ],
            ),
          ),
          Expanded(
            child: ref.watch(getCompaniesProvider).when(
                  data: (companies) {
                    final filteredCompanies = companies.where((company) {
                      final nameMatches = _search.isEmpty ||
                          company.companyName
                              .toLowerCase()
                              .contains(_search.toLowerCase());
                      final industryMatches = _selectedIndustryId == null ||
                          company.industryId == _selectedIndustryId;
                      return nameMatches && industryMatches;
                    }).toList();

                    if (filteredCompanies.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredCompanies.length,
                      itemBuilder: (context, index) {
                        final company = filteredCompanies[index];
                        return _buildCompanyCard(company);
                      },
                    );
                  },
                  error: (error, stackTrace) => ErrorPage(
                    error: error.toString(),
                  ),
                  loading: () => const LoadingPage(),
                ),
          ),
        ],
      ),
    );
  }

  /// Build the industry filter dropdown
  Widget _buildIndustryFilter() {
    return ref.watch(getIndustriesProvider).when(
      data: (industries) {
        if (industries.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter by Industry',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).scaffoldBackgroundColor,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  hint: const Text('Select an industry'),
                  value: _selectedIndustryId,
                  icon: const Icon(Icons.keyboard_arrow_down),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All Industries'),
                    ),
                    ...industries.map((industry) {
                      return DropdownMenuItem<String>(
                        value: industry.id,
                        child: Text(
                          industry.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedIndustryId = value;
                      _selectedIndustry = value != null
                          ? industries.firstWhere((i) => i.id == value)
                          : null;
                    });
                    Loggers.database.info(
                        'Industry filter changed to: ${_selectedIndustry?.name ?? "All"}');
                  },
                ),
              ),
            ),
            if (_selectedIndustry != null) ...[
              const SizedBox(height: 8),
              Chip(
                label: Text(_selectedIndustry!.name),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () {
                  setState(() {
                    _selectedIndustryId = null;
                    _selectedIndustry = null;
                  });
                },
              ),
            ],
          ],
        );
      },
      loading: () => const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, stackTrace) {
        Loggers.database.error('Error loading industries: $error');
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Failed to load industries',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Build a company card widget
  Widget _buildCompanyCard(CompanyModel company) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          child: company.logoUrl.isNotEmpty
              ? ClipOval(
                  child: Image.network(
                    company.logoUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.business, color: Theme.of(context).primaryColor);
                    },
                  ),
                )
              : Icon(Icons.business, color: Theme.of(context).primaryColor),
        ),
        title: Text(
          company.companyName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(company.industryName ?? 'Industry not specified'),
            const SizedBox(height: 4),
            Text(
              'Commission: \$${company.commissionPerOrder.toStringAsFixed(2)}',
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: company.isActive 
                ? Colors.green.withOpacity(0.1) 
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            company.isActive ? 'Active' : 'Inactive',
            style: TextStyle(
              color: company.isActive ? Colors.green[700] : Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        onTap: () => _showCompanyProfile(context, company),
      ),
    );
  }

  /// Build empty state widget
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No companies found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              _search.isNotEmpty || _selectedIndustryId != null
                  ? 'Try adjusting your search or filter criteria'
                  : 'Companies will appear here when available',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            if (_search.isNotEmpty || _selectedIndustryId != null) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _search = '';
                    _selectedIndustryId = null;
                    _selectedIndustry = null;
                  });
                },
                icon: const Icon(Icons.clear),
                label: const Text('Clear filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCompanyProfile(BuildContext context, CompanyModel company) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                children: [
                  if (company.logoUrl.isNotEmpty)
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Theme.of(context).primaryColor.withOpacity(0.1),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          company.logoUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.business,
                              color: Theme.of(context).primaryColor,
                              size: 30,
                            );
                          },
                        ),
                      ),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          company.companyName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: company.isActive 
                                ? Colors.green.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            company.isActive ? 'Active' : 'Inactive',
                            style: TextStyle(
                              color: company.isActive ? Colors.green[700] : Colors.grey[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (company.description.isNotEmpty) ...[
                Text(
                  company.description,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              _buildInfoRow(
                icon: Icons.category,
                label: 'Industry',
                value: company.industryName ?? 'Not specified',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.inventory,
                label: 'Products',
                value: company.products.isNotEmpty 
                    ? company.products.join(', ') 
                    : 'No products listed',
              ),
              const SizedBox(height: 8),
              _buildInfoRow(
                icon: Icons.monetization_on,
                label: 'Commission per Order',
                value: '\$${company.commissionPerOrder.toStringAsFixed(2)}',
                valueColor: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: company.isActive ? () async {
                    ref
                        .read(companyControllerProvider.notifier)
                        .addCompanyToProfile(
                          companyId: company.id,
                          context: context,
                        );
                  } : null,
                  icon: const Icon(Icons.add),
                  label: Text(company.isActive 
                      ? 'Add to my profile' 
                      : 'Company not active'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}