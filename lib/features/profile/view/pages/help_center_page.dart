import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class HelpCenterPage extends StatefulWidget {
  const HelpCenterPage({super.key});

  @override
  State<HelpCenterPage> createState() => _HelpCenterPageState();
}

class _HelpCenterPageState extends State<HelpCenterPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<FAQItem> _faqItems = [
    FAQItem(
      question: 'How do I create an order?',
      answer: 'To create an order, go to the Orders tab and tap the "+" button. Fill in the customer details, select a company and product, then submit the order.',
      category: 'Orders',
    ),
    FAQItem(
      question: 'How do I get verified?',
      answer: 'Go to your profile and tap "Get Verified". Upload your ID document, fill in your address, and submit for review. Verification usually takes 1-3 business days.',
      category: 'Account',
    ),
    FAQItem(
      question: 'How do I withdraw my earnings?',
      answer: 'Go to the Wallet tab, tap "Withdraw", add your bank account details, and submit a withdrawal request. Funds are typically processed within 2-5 business days.',
      category: 'Wallet',
    ),
    FAQItem(
      question: 'How do I add a company to my profile?',
      answer: 'Go to the Companies tab, search for the company you want to work with, and tap "Add to my profile". The company will review your request.',
      category: 'Companies',
    ),
    FAQItem(
      question: 'What commission rates can I expect?',
      answer: 'Commission rates vary by company and product. You can see the commission rate for each company in their profile before adding them to your portfolio.',
      category: 'Earnings',
    ),
    FAQItem(
      question: 'How do I update my profile information?',
      answer: 'Go to your profile and tap "Get Verified" or "Update Verification Info" to edit your personal information, address, and profile picture.',
      category: 'Account',
    ),
    FAQItem(
      question: 'What should I do if an order is rejected?',
      answer: 'If an order is rejected, check the rejection reason in the order details. Contact the company directly or reach out to support for assistance.',
      category: 'Orders',
    ),
    FAQItem(
      question: 'How do I contact customer support?',
      answer: 'You can contact support through the Help Center, send an email to support@fieldforce.com, or use the in-app chat feature.',
      category: 'Support',
    ),
  ];

  List<FAQItem> get _filteredFAQs {
    if (_searchQuery.isEmpty) return _faqItems;
    return _faqItems.where((faq) {
      return faq.question.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             faq.answer.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             faq.category.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for help...',
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

            const SizedBox(height: 24),

            // Quick Actions Section
            SettingsSection(
              title: 'Quick Actions',
              icon: Symbols.support_agent,
              children: [
                SettingsTile(
                  title: 'Contact Support',
                  subtitle: 'Get help from our support team',
                  icon: Symbols.headset_mic,
                  onTap: () => _showContactSupportDialog(context),
                ),
                SettingsTile(
                  title: 'Live Chat',
                  subtitle: 'Chat with support in real-time',
                  icon: Symbols.chat,
                  onTap: () => _showLiveChatDialog(context),
                ),
                SettingsTile(
                  title: 'Report a Bug',
                  subtitle: 'Report technical issues',
                  icon: Symbols.bug_report,
                  onTap: () => _showBugReportDialog(context),
                ),
                SettingsTile(
                  title: 'Feature Request',
                  subtitle: 'Suggest new features',
                  icon: Symbols.lightbulb,
                  onTap: () => _showFeatureRequestDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // App Guide Section
            SettingsSection(
              title: 'App Guide',
              icon: Symbols.menu_book,
              children: [
                SettingsTile(
                  title: 'Getting Started',
                  subtitle: 'Learn the basics of using FieldForce',
                  icon: Symbols.play_circle,
                  onTap: () => _showGettingStartedDialog(context),
                ),
                SettingsTile(
                  title: 'Video Tutorials',
                  subtitle: 'Watch step-by-step guides',
                  icon: Symbols.video_library,
                  onTap: () => _showVideoTutorialsDialog(context),
                ),
                SettingsTile(
                  title: 'Best Practices',
                  subtitle: 'Tips for successful field sales',
                  icon: Symbols.star,
                  onTap: () => _showBestPracticesDialog(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),

            if (_filteredFAQs.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Symbols.search_off,
                        size: 48,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try different keywords or contact support',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              )
            else
              ...(_filteredFAQs.map((faq) => _buildFAQItem(faq))),

            const SizedBox(height: 24),

            // Contact Information
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Symbols.contact_support,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Still Need Help?',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildContactInfo(Symbols.email, 'Email', 'support@fieldforce.com'),
                    const SizedBox(height: 8),
                    _buildContactInfo(Symbols.phone, 'Phone', '+1 (555) 123-4567'),
                    const SizedBox(height: 8),
                    _buildContactInfo(Symbols.schedule, 'Hours', 'Mon-Fri 9AM-6PM EST'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(FAQItem faq) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        leading: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
          ),
          child: Icon(
            Symbols.help,
            size: 18,
            color: Theme.of(context).primaryColor,
          ),
        ),
        title: Text(
          faq.question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          faq.category,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 12,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              faq.answer,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
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
                const SnackBar(content: Text('Support ticket submitted')),
              );
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  void _showLiveChatDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Symbols.chat, size: 48, color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Live chat feature is coming soon!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'For now, please use email or phone support.',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
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

  void _showBugReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report a Bug'),
        content: const Text(
          'To report a bug, please email us at bugs@fieldforce.com with:\n\n'
          '• Description of the issue\n'
          '• Steps to reproduce\n'
          '• Screenshots (if applicable)\n'
          '• Your device information',
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

  void _showFeatureRequestDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feature Request'),
        content: const Text(
          'We love hearing your ideas! Send your feature requests to:\n\n'
          'features@fieldforce.com\n\n'
          'Please include:\n'
          '• Detailed description\n'
          '• How it would help you\n'
          '• Any examples or mockups',
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

  void _showGettingStartedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Getting Started'),
        content: const Text(
          'Welcome to FieldForce! Here\'s how to get started:\n\n'
          '1. Complete your profile verification\n'
          '2. Browse and add companies to your portfolio\n'
          '3. Start creating orders for customers\n'
          '4. Track your earnings in the wallet\n'
          '5. Withdraw your earnings to your bank account',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showVideoTutorialsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Video Tutorials'),
        content: const Text(
          'Video tutorials are coming soon!\n\n'
          'We\'re creating comprehensive video guides to help you make the most of FieldForce.\n\n'
          'For now, check out our FAQ section or contact support for help.',
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

  void _showBestPracticesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Best Practices'),
        content: const Text(
          'Tips for successful field sales:\n\n'
          '• Keep your profile complete and verified\n'
          '• Respond quickly to customer inquiries\n'
          '• Maintain accurate order information\n'
          '• Build relationships with companies\n'
          '• Track your performance regularly\n'
          '• Stay updated on product information',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Thanks'),
          ),
        ],
      ),
    );
  }
}

class FAQItem {
  final String question;
  final String answer;
  final String category;

  FAQItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}