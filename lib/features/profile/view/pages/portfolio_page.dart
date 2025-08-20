import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:fieldforce/features/auth/controller/auth_controller.dart';
import 'package:fieldforce/features/wallet/provider/wallet_provider.dart';
import 'package:fieldforce/features/order/provider/order_provider.dart';
import 'package:fieldforce/theme/app_colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

class PortfolioPage extends ConsumerWidget {
  const PortfolioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider);
    final userWallet = ref.watch(getUserWalletProvider);
    final userOrders = ref.watch(getOrdersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Portfolio'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Performance Overview Card
            _buildPerformanceOverviewCard(context, userWallet, userOrders),

            const SizedBox(height: 24),

            // Professional Profile Section
            SettingsSection(
              title: 'Professional Profile',
              icon: Symbols.person,
              children: [
                currentUser.when(
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();
                    return Column(
                      children: [
                        SettingsTile(
                          title: 'Professional Bio',
                          subtitle: 'Add your professional background',
                          icon: Symbols.description,
                          onTap: () => _showProfessionalBioDialog(context),
                        ),
                        SettingsTile(
                          title: 'Skills & Expertise',
                          subtitle: 'Showcase your skills',
                          icon: Symbols.star,
                          onTap: () => _showSkillsDialog(context),
                        ),
                        SettingsTile(
                          title: 'Certifications',
                          subtitle: 'Add professional certifications',
                          icon: Symbols.workspace_premium,
                          onTap: () => _showCertificationsDialog(context),
                        ),
                      ],
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => const SizedBox.shrink(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Performance Metrics Section
            SettingsSection(
              title: 'Performance Metrics',
              icon: Symbols.analytics,
              children: [
                SettingsTile(
                  title: 'Sales Performance',
                  subtitle: 'View detailed sales analytics',
                  icon: Symbols.trending_up,
                  onTap: () => _showSalesPerformanceDialog(context, userOrders),
                ),
                SettingsTile(
                  title: 'Customer Feedback',
                  subtitle: 'Reviews and testimonials',
                  icon: Symbols.reviews,
                  onTap: () => _showCustomerFeedbackDialog(context),
                ),
                SettingsTile(
                  title: 'Achievement Badges',
                  subtitle: 'Your earned achievements',
                  icon: Symbols.military_tech,
                  onTap: () => _showAchievementsDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Company Associations Section
            SettingsSection(
              title: 'Company Associations',
              icon: Symbols.business,
              children: [
                SettingsTile(
                  title: 'Partner Companies',
                  subtitle: 'Companies you work with',
                  icon: Symbols.handshake,
                  onTap: () => _showPartnerCompaniesDialog(context),
                ),
                SettingsTile(
                  title: 'Industry Expertise',
                  subtitle: 'Your industry specializations',
                  icon: Symbols.category,
                  onTap: () => _showIndustryExpertiseDialog(context),
                ),
                SettingsTile(
                  title: 'Territory Coverage',
                  subtitle: 'Areas you serve',
                  icon: Symbols.map,
                  onTap: () => _showTerritoryCoverageDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceOverviewCard(BuildContext context, AsyncValue userWallet, AsyncValue userOrders) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [kPrimary, kPrimary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Symbols.dashboard,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Performance Overview',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Earnings',
                    userWallet.when(
                      data: (wallet) => wallet != null ? '\$${wallet.totalEarnings.toStringAsFixed(2)}' : '\$0.00',
                      loading: () => '...',
                      error: (_, __) => '\$0.00',
                    ),
                    Symbols.attach_money,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Total Orders',
                    userOrders.when(
                      data: (orders) => orders.length.toString(),
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Symbols.shopping_bag,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'Success Rate',
                    userOrders.when(
                      data: (orders) {
                        if (orders.isEmpty) return '0%';
                        final completed = orders.where((o) => o.orderStatus.toString().contains('delivered')).length;
                        final rate = (completed / orders.length * 100).round();
                        return '$rate%';
                      },
                      loading: () => '...',
                      error: (_, __) => '0%',
                    ),
                    Symbols.check_circle,
                  ),
                ),
                Expanded(
                  child: _buildMetricItem(
                    context,
                    'This Month',
                    userOrders.when(
                      data: (orders) {
                        final thisMonth = orders.where((o) {
                          final now = DateTime.now();
                          return o.createdAt.month == now.month && o.createdAt.year == now.year;
                        }).length;
                        return thisMonth.toString();
                      },
                      loading: () => '...',
                      error: (_, __) => '0',
                    ),
                    Symbols.calendar_month,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white70, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.white70,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showProfessionalBioDialog(BuildContext context) {
    final bioController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Professional Bio'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Tell companies about your professional background and experience:'),
            const SizedBox(height: 16),
            TextField(
              controller: bioController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter your professional bio...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Professional bio saved')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSkillsDialog(BuildContext context) {
    final skills = [
      'Sales Strategy', 'Customer Relations', 'Product Knowledge',
      'Negotiation', 'Lead Generation', 'Market Analysis',
      'Communication', 'Time Management', 'CRM Software',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skills & Expertise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your key skills:'),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: ListView.builder(
                itemCount: skills.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(skills[index]),
                    value: false,
                    onChanged: (value) {},
                  );
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Skills updated')),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showCertificationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Certifications'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.workspace_premium, size: 48, color: Colors.amber),
            SizedBox(height: 16),
            Text('Add your professional certifications to showcase your expertise to companies.'),
            SizedBox(height: 16),
            Text('This feature will be available in a future update.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSalesPerformanceDialog(BuildContext context, AsyncValue userOrders) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sales Performance'),
        content: userOrders.when(
          data: (orders) {
            final totalOrders = orders.length;
            final completedOrders = orders.where((o) => o.orderStatus.toString().contains('delivered')).length;
            final pendingOrders = orders.where((o) => o.orderStatus.toString().contains('pending')).length;
            final rejectedOrders = orders.where((o) => o.orderStatus.toString().contains('rejected')).length;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPerformanceRow('Total Orders', totalOrders.toString()),
                _buildPerformanceRow('Completed', completedOrders.toString()),
                _buildPerformanceRow('Pending', pendingOrders.toString()),
                _buildPerformanceRow('Rejected', rejectedOrders.toString()),
                const Divider(),
                _buildPerformanceRow(
                  'Success Rate', 
                  totalOrders > 0 ? '${(completedOrders / totalOrders * 100).round()}%' : '0%'
                ),
              ],
            );
          },
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => const Text('Unable to load performance data'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showCustomerFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Customer Feedback'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.reviews, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text('Customer reviews and testimonials will appear here once you start completing orders.'),
            SizedBox(height: 16),
            Text('This feature will be enhanced in future updates.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showAchievementsDialog(BuildContext context) {
    final achievements = [
      {'title': 'First Order', 'description': 'Complete your first order', 'earned': true},
      {'title': 'Top Performer', 'description': 'Achieve 95% success rate', 'earned': false},
      {'title': 'Customer Favorite', 'description': 'Receive 10 five-star reviews', 'earned': false},
      {'title': 'Sales Champion', 'description': 'Complete 100 orders', 'earned': false},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Achievement Badges'),
        content: SizedBox(
          height: 300,
          child: ListView.builder(
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return ListTile(
                leading: Icon(
                  Symbols.military_tech,
                  color: achievement['earned'] as bool ? Colors.amber : Colors.grey,
                ),
                title: Text(achievement['title'] as String),
                subtitle: Text(achievement['description'] as String),
                trailing: achievement['earned'] as bool 
                    ? const Icon(Symbols.check_circle, color: Colors.green)
                    : const Icon(Symbols.lock, color: Colors.grey),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showPartnerCompaniesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Partner Companies'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.handshake, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text('Your partner companies and collaboration history will be displayed here.'),
            SizedBox(height: 16),
            Text('Add companies to your portfolio to start building partnerships.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showIndustryExpertiseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Industry Expertise'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.category, size: 48, color: Colors.purple),
            SizedBox(height: 16),
            Text('Your industry specializations and expertise levels will be shown here.'),
            SizedBox(height: 16),
            Text('Complete orders in different industries to build your expertise profile.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTerritoryCoverageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Territory Coverage'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.map, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text('Your service areas and territory coverage will be displayed here.'),
            SizedBox(height: 16),
            Text('This feature will include interactive maps in future updates.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}