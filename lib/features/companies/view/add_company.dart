import 'package:fieldforce/apis/industry_api.dart';
import 'package:fieldforce/features/company/model/industry_model.dart';
import 'package:fieldforce/features/companies/model/company_model.dart';
import 'package:fieldforce/features/companies/providers/company_provider.dart';
import 'package:fieldforce/utils/error_page.dart';
import 'package:fieldforce/utils/loading_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getIndustriesProvider = FutureProvider<List<IndustryModel>>((ref) async {
  final industryAPI = ref.watch(industryAPIProvider);
  final res = await industryAPI.getIndustries();
  return res.fold((l) => <IndustryModel>[], (r) => r);
});

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
  String? _selectedIndustry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Company'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ref.watch(getCompaniesProvider).when(
                  data: (companies) {
                    return ref.watch(getIndustriesProvider).when(
                          data: (industries) {
                            return Column(
                              children: [
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Search by name',
                                    prefixIcon: Icon(Icons.search),
                                  ),
                                  onChanged: (value) {
                                    setState(() => _search = value);
                                  },
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    DropdownButton<String>(
                                      hint: const Text('Industry'),
                                      value: _selectedIndustry,
                                      items: industries.map((industry) {
                                        return DropdownMenuItem<String>(
                                          value: industry.id,
                                          child: Text(industry.name),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(
                                            () => _selectedIndustry = value);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                          error: (e, st) => const SizedBox(),
                          loading: () => const SizedBox(),
                        );
                  },
                  error: (e, st) => const SizedBox(),
                  loading: () => const SizedBox(),
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
                      final industryMatches = _selectedIndustry == null ||
                          company.industryId ==
                              _selectedIndustry; // Use industryId for matching
                      return nameMatches && industryMatches;
                    }).toList();

                    return ListView.builder(
                      itemCount: filteredCompanies.length,
                      itemBuilder: (context, index) {
                        final company = filteredCompanies[index];
                        return ListTile(
                          title: Text(company.companyName),
                          subtitle: Text(company.industryName ??
                              'N/A'), // Display industryName
                          onTap: () => _showCompanyProfile(context, company),
                        );
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
              Text(
                company.companyName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                company.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text(
                  'Industry: ${company.industryName ?? 'N/A'}'), // Display industryName
              const SizedBox(height: 8),
              Text('Products: ${company.products.join(', ')}'),
              const SizedBox(height: 8),
              Text('Commission per Order: ${company.commissionPerOrder}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    ref
                        .read(companyControllerProvider.notifier)
                        .addCompanyToProfile(
                          companyId: company.id,
                          context: context,
                        );
                  },
                  child: const Text('Add to my profile'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
