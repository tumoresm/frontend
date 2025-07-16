import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddCompanyPage extends ConsumerStatefulWidget {
  static Route<void> route() => MaterialPageRoute(
        builder: (context) => const AddCompanyPage(),
      );
  const AddCompanyPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AddCompanyPageState();
}

class _AddCompanyPageState extends ConsumerState<AddCompanyPage> {
  String _search = '';
  String? _selectedIndustry;

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual company fetching logic
    final companies = <Map<String, dynamic>>[]; // Placeholder for company list

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Company'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Search by name',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (value) {
                      setState(() => _search = value);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  hint: const Text('Industry'),
                  value: _selectedIndustry,
                  items: <String>[].map((industry) {
                    return DropdownMenuItem<String>(
                      value: industry,
                      child: Text(industry),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedIndustry = value);
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return ListTile(
                  title: Text(company['name'] ?? ''),
                  subtitle: Text(company['industry'] ?? ''),
                  onTap: () => _showCompanyProfile(context, company),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showCompanyProfile(BuildContext context, Map<String, dynamic> company) {
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
                company['name'] ?? '',
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 8),
              Text(
                company['description'] ?? '',
                style: Theme.of(context).textTheme.bodyText2,
              ),
              const SizedBox(height: 12),
              Text('Industry: ${company['industry'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Products: ${company['products'] ?? ''}'),
              const SizedBox(height: 8),
              Text(
                  'Commission per Order: ${company['commissionPerOrder'] ?? ''}'),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement add to rep profile logic
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
