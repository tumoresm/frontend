import 'package:fieldforce/features/profile/view/widgets/settings_section.dart';
import 'package:fieldforce/features/profile/view/widgets/settings_tile.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class LegalTermsPage extends StatelessWidget {
  const LegalTermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal Terms'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal Documents Section
            SettingsSection(
              title: 'Legal Documents',
              icon: Symbols.gavel,
              children: [
                SettingsTile(
                  title: 'Terms of Service',
                  subtitle: 'Last updated: January 2024',
                  icon: Symbols.description,
                  onTap: () => _showTermsOfService(context),
                ),
                SettingsTile(
                  title: 'Privacy Policy',
                  subtitle: 'Last updated: January 2024',
                  icon: Symbols.privacy_tip,
                  onTap: () => _showPrivacyPolicy(context),
                ),
                SettingsTile(
                  title: 'User Agreement',
                  subtitle: 'Last updated: January 2024',
                  icon: Symbols.handshake,
                  onTap: () => _showUserAgreement(context),
                ),
                SettingsTile(
                  title: 'Cookie Policy',
                  subtitle: 'How we use cookies',
                  icon: Symbols.cookie,
                  onTap: () => _showCookiePolicy(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Rep Agreements Section
            SettingsSection(
              title: 'Rep Agreements',
              icon: Symbols.contract,
              children: [
                SettingsTile(
                  title: 'Rep Agreement',
                  subtitle: 'Your agreement as a field sales representative',
                  icon: Symbols.assignment,
                  onTap: () => _showRepAgreement(context),
                ),
                SettingsTile(
                  title: 'Commission Structure',
                  subtitle: 'How commissions are calculated',
                  icon: Symbols.calculate,
                  onTap: () => _showCommissionStructure(context),
                ),
                SettingsTile(
                  title: 'Non-Disclosure Agreement',
                  subtitle: 'Confidentiality requirements',
                  icon: Symbols.security,
                  onTap: () => _showNDA(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Compliance Section
            SettingsSection(
              title: 'Compliance & Rights',
              icon: Symbols.verified_user,
              children: [
                SettingsTile(
                  title: 'GDPR Rights',
                  subtitle: 'Your data protection rights',
                  icon: Symbols.shield,
                  onTap: () => _showGDPRRights(context),
                ),
                SettingsTile(
                  title: 'Data Processing Consent',
                  subtitle: 'Manage your data processing preferences',
                  icon: Symbols.data_usage,
                  onTap: () => _showDataProcessingConsent(context),
                ),
                SettingsTile(
                  title: 'Compliance Reporting',
                  subtitle: 'Report compliance issues',
                  icon: Symbols.report,
                  onTap: () => _showComplianceReporting(context),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Legal Information Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                          'Legal Information',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'FieldForce is committed to transparency and compliance with all applicable laws and regulations. '
                      'By using our services, you agree to be bound by these terms and conditions.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(
                          Symbols.business,
                          size: 16,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'FieldForce Technologies Inc.\n123 Business Ave, Suite 100\nNew York, NY 10001',
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
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    _showLegalDocument(
      context,
      'Terms of Service',
      '''
FIELDFORCE TERMS OF SERVICE

Last Updated: January 2024

1. ACCEPTANCE OF TERMS
By accessing and using the FieldForce application, you accept and agree to be bound by the terms and provision of this agreement.

2. DESCRIPTION OF SERVICE
FieldForce is a platform that connects field sales representatives with companies seeking sales services.

3. USER RESPONSIBILITIES
- Provide accurate and complete information
- Maintain the confidentiality of your account
- Use the service in compliance with all applicable laws
- Respect the rights of other users and companies

4. PROHIBITED ACTIVITIES
- Fraudulent or deceptive practices
- Harassment or abuse of other users
- Violation of intellectual property rights
- Unauthorized access to the system

5. COMMISSION AND PAYMENTS
- Commissions are paid according to the agreed terms with each company
- FieldForce may charge service fees as disclosed
- Payment processing may take 2-5 business days

6. TERMINATION
Either party may terminate this agreement at any time with proper notice.

7. LIMITATION OF LIABILITY
FieldForce shall not be liable for any indirect, incidental, or consequential damages.

8. GOVERNING LAW
This agreement shall be governed by the laws of the State of New York.

For complete terms, please visit our website or contact legal@fieldforce.com
      ''',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    _showLegalDocument(
      context,
      'Privacy Policy',
      '''
FIELDFORCE PRIVACY POLICY

Last Updated: January 2024

1. INFORMATION WE COLLECT
- Personal information (name, email, phone number)
- Professional information (work history, skills)
- Usage data and analytics
- Location data (with your consent)

2. HOW WE USE YOUR INFORMATION
- To provide and improve our services
- To process payments and commissions
- To communicate with you about your account
- To ensure security and prevent fraud

3. INFORMATION SHARING
We do not sell your personal information. We may share information:
- With companies you choose to work with
- With service providers who assist our operations
- When required by law or to protect our rights

4. DATA SECURITY
We implement appropriate security measures to protect your information against unauthorized access, alteration, disclosure, or destruction.

5. YOUR RIGHTS
- Access your personal information
- Correct inaccurate information
- Delete your account and data
- Opt-out of marketing communications

6. COOKIES AND TRACKING
We use cookies and similar technologies to improve your experience and analyze usage patterns.

7. CHILDREN'S PRIVACY
Our service is not intended for children under 18 years of age.

8. INTERNATIONAL TRANSFERS
Your information may be transferred to and processed in countries other than your own.

9. CHANGES TO THIS POLICY
We may update this policy from time to time. We will notify you of any material changes.

For questions about this policy, contact privacy@fieldforce.com
      ''',
    );
  }

  void _showUserAgreement(BuildContext context) {
    _showLegalDocument(
      context,
      'User Agreement',
      '''
FIELDFORCE USER AGREEMENT

Last Updated: January 2024

1. ELIGIBILITY
To use FieldForce, you must:
- Be at least 18 years old
- Have the legal capacity to enter into contracts
- Provide accurate and complete information
- Comply with all applicable laws

2. ACCOUNT REGISTRATION
- You are responsible for maintaining account security
- You must verify your identity as required
- One account per person is permitted
- You must keep your information current

3. PROFESSIONAL CONDUCT
As a FieldForce representative, you agree to:
- Maintain professional standards
- Represent companies honestly and accurately
- Provide excellent customer service
- Follow all company-specific guidelines

4. INTELLECTUAL PROPERTY
- FieldForce retains all rights to the platform
- You retain rights to your original content
- You grant us license to use your content as needed
- Respect third-party intellectual property rights

5. DISPUTE RESOLUTION
- First attempt to resolve disputes directly
- Mediation may be required for unresolved issues
- Binding arbitration for legal disputes
- Class action waiver applies

6. MODIFICATIONS
We may modify this agreement with notice to users. Continued use constitutes acceptance of changes.

7. SEVERABILITY
If any provision is found unenforceable, the remainder of the agreement remains in effect.

For questions, contact legal@fieldforce.com
      ''',
    );
  }

  void _showCookiePolicy(BuildContext context) {
    _showLegalDocument(
      context,
      'Cookie Policy',
      '''
FIELDFORCE COOKIE POLICY

Last Updated: January 2024

1. WHAT ARE COOKIES
Cookies are small text files stored on your device when you visit our website or use our app.

2. TYPES OF COOKIES WE USE

Essential Cookies:
- Required for the service to function
- Cannot be disabled
- Include authentication and security cookies

Analytics Cookies:
- Help us understand how you use our service
- Provide insights for improvements
- Can be disabled in settings

Functional Cookies:
- Remember your preferences
- Enhance your user experience
- Can be disabled in settings

Marketing Cookies:
- Used for targeted advertising
- Track your interests and behavior
- Can be disabled in settings

3. THIRD-PARTY COOKIES
We may use third-party services that set their own cookies:
- Google Analytics
- Payment processors
- Customer support tools

4. MANAGING COOKIES
You can control cookies through:
- Your browser settings
- Our app settings
- Third-party opt-out tools

5. MOBILE APP DATA
Our mobile app may collect similar information through:
- Device identifiers
- App usage analytics
- Crash reporting tools

6. UPDATES
This policy may be updated to reflect changes in our practices or applicable laws.

For questions about cookies, contact privacy@fieldforce.com
      ''',
    );
  }

  void _showRepAgreement(BuildContext context) {
    _showLegalDocument(
      context,
      'Rep Agreement',
      '''
FIELDFORCE REPRESENTATIVE AGREEMENT

Last Updated: January 2024

1. INDEPENDENT CONTRACTOR STATUS
You are an independent contractor, not an employee of FieldForce or any partner company.

2. SERVICES PROVIDED
As a FieldForce representative, you will:
- Generate sales leads and opportunities
- Present products and services to customers
- Process orders through the platform
- Maintain customer relationships

3. COMMISSION STRUCTURE
- Commissions vary by company and product
- Rates are clearly displayed before accepting work
- Payments processed within 2-5 business days
- FieldForce may charge platform fees

4. PERFORMANCE STANDARDS
- Maintain professional conduct at all times
- Meet quality standards set by partner companies
- Respond promptly to customer inquiries
- Accurate reporting of all activities

5. TERRITORY AND EXCLUSIVITY
- No exclusive territories unless specifically agreed
- Multiple reps may work in the same area
- Respect other reps' customer relationships
- Follow company-specific territory rules

6. TRAINING AND SUPPORT
- Complete required training programs
- Stay updated on product information
- Use provided marketing materials appropriately
- Participate in ongoing education

7. CONFIDENTIALITY
- Protect confidential company information
- Do not share customer data inappropriately
- Maintain trade secret confidentiality
- Report security breaches immediately

8. TERMINATION
- Either party may terminate with notice
- Outstanding commissions will be paid
- Return any company materials
- Confidentiality obligations continue

For questions, contact reps@fieldforce.com
      ''',
    );
  }

  void _showCommissionStructure(BuildContext context) {
    _showLegalDocument(
      context,
      'Commission Structure',
      '''
FIELDFORCE COMMISSION STRUCTURE

Last Updated: January 2024

1. COMMISSION BASICS
- Commissions are earned on completed, paid orders
- Rates vary by company, product, and volume
- Clearly displayed before accepting assignments
- Paid within 2-5 business days of order completion

2. COMMISSION TYPES

Flat Rate:
- Fixed amount per order
- Common for simple products
- Easy to calculate and predict

Percentage:
- Percentage of order value
- Typical range: 2-15%
- Higher for complex sales

Tiered:
- Increases with volume
- Rewards high performers
- Monthly or quarterly tiers

3. PAYMENT SCHEDULE
- Weekly payment cycles
- Minimum payout threshold: R25
- Direct deposit to verified bank account
- Payment history available in app

4. DEDUCTIONS
FieldForce may deduct:
- Platform service fees (typically 3-5%)
- Payment processing fees
- Chargebacks for returned orders
- Compliance violations

5. BONUSES AND INCENTIVES
- Performance bonuses available
- Company-specific incentives
- Seasonal promotions
- Referral bonuses for new reps

6. TAX RESPONSIBILITIES
- You are responsible for all taxes
- 1099 forms provided annually
- Consult tax professional for advice
- Keep detailed records

7. DISPUTES
- Report commission discrepancies immediately
- Review process within 30 days
- Appeal process available
- Final decisions binding

For commission questions, contact payments@fieldforce.com
      ''',
    );
  }

  void _showNDA(BuildContext context) {
    _showLegalDocument(
      context,
      'Non-Disclosure Agreement',
      '''
FIELDFORCE NON-DISCLOSURE AGREEMENT

Last Updated: January 2024

1. CONFIDENTIAL INFORMATION
Confidential information includes:
- Customer lists and contact information
- Pricing strategies and commission rates
- Product development information
- Business strategies and plans
- Technical specifications
- Financial information

2. OBLIGATIONS
You agree to:
- Keep all confidential information secret
- Use information only for authorized purposes
- Not disclose to unauthorized parties
- Protect information with reasonable care
- Return information upon termination

3. EXCEPTIONS
This agreement does not apply to information that:
- Is publicly available
- Was known before disclosure
- Is independently developed
- Is required to be disclosed by law

4. DURATION
- Confidentiality obligations continue indefinitely
- Survives termination of other agreements
- Applies to all information received
- Covers information from all sources

5. REMEDIES
Breach of this agreement may result in:
- Immediate termination
- Legal action for damages
- Injunctive relief
- Recovery of attorney fees

6. THIRD PARTIES
- Do not disclose to family or friends
- Ensure any assistants sign similar agreements
- Protect information in all communications
- Use secure methods for data handling

7. RETURN OF INFORMATION
Upon termination or request:
- Return all confidential materials
- Delete electronic copies
- Confirm destruction in writing
- Continue confidentiality obligations

For questions about confidentiality, contact legal@fieldforce.com
      ''',
    );
  }

  void _showGDPRRights(BuildContext context) {
    _showLegalDocument(
      context,
      'GDPR Rights',
      '''
YOUR GDPR RIGHTS

Under the General Data Protection Regulation (GDPR), you have the following rights:

1. RIGHT TO BE INFORMED
- Know what personal data we collect
- Understand how we use your data
- Know who we share data with
- Understand your rights

2. RIGHT OF ACCESS
- Request a copy of your personal data
- Receive information about processing
- Get details about data sharing
- Understand automated decision-making

3. RIGHT TO RECTIFICATION
- Correct inaccurate personal data
- Complete incomplete data
- Update outdated information
- Fix errors in your profile

4. RIGHT TO ERASURE
- Request deletion of your data
- "Right to be forgotten"
- Applies when data no longer needed
- Subject to legal requirements

5. RIGHT TO RESTRICT PROCESSING
- Limit how we use your data
- Temporary restriction available
- While disputes are resolved
- When accuracy is contested

6. RIGHT TO DATA PORTABILITY
- Receive your data in structured format
- Transfer data to another service
- Machine-readable format provided
- Applies to automated processing

7. RIGHT TO OBJECT
- Object to processing for marketing
- Object to automated decision-making
- Object to profiling
- Opt-out of data processing

8. RIGHTS RELATED TO AUTOMATED DECISION-MAKING
- Not subject to automated decisions
- Request human intervention
- Express your point of view
- Contest automated decisions

To exercise your rights, contact privacy@fieldforce.com
      ''',
    );
  }

  void _showDataProcessingConsent(BuildContext context) {
    _showLegalDocument(
      context,
      'Data Processing Consent',
      '''
DATA PROCESSING CONSENT MANAGEMENT

You have control over how your personal data is processed:

1. CONSENT CATEGORIES

Essential Processing:
- Required for service operation
- Cannot be withdrawn
- Includes account management
- Security and fraud prevention

Marketing Communications:
- Promotional emails and notifications
- Product updates and offers
- Can be withdrawn anytime
- Granular control available

Analytics and Improvement:
- Usage analytics and insights
- Service improvement research
- Performance optimization
- Can be withdrawn

Personalization:
- Customized user experience
- Targeted content delivery
- Preference-based features
- Can be withdrawn

2. MANAGING CONSENT
- Update preferences in app settings
- Email unsubscribe links available
- Contact privacy team for assistance
- Changes take effect immediately

3. WITHDRAWAL OF CONSENT
- Right to withdraw at any time
- Does not affect past processing
- May limit service functionality
- Alternative options may be available

4. CONSENT RECORDS
- We maintain records of your consent
- Includes date, time, and method
- Available upon request
- Used for compliance purposes

5. CHILDREN'S DATA
- Special protections for minors
- Parental consent required
- Enhanced privacy safeguards
- Limited data collection

6. INTERNATIONAL TRANSFERS
- Consent for data transfers
- Adequate protection measures
- Right to object to transfers
- Alternative arrangements available

To manage your consent preferences, visit Settings > Privacy or contact privacy@fieldforce.com
      ''',
    );
  }

  void _showComplianceReporting(BuildContext context) {
    _showLegalDocument(
      context,
      'Compliance Reporting',
      '''
COMPLIANCE REPORTING

FieldForce is committed to maintaining the highest standards of legal and ethical compliance.

1. REPORTING VIOLATIONS
Report any suspected violations of:
- Terms of service
- Privacy policies
- Legal requirements
- Ethical standards
- Company policies

2. REPORTING METHODS

Email: compliance@fieldforce.com
- Detailed description of issue
- Supporting documentation
- Contact information
- Preferred response method

In-App Reporting:
- Use built-in reporting tools
- Anonymous reporting available
- Automatic case tracking
- Status updates provided

Phone: 1-800-COMPLIANCE
- Speak with compliance officer
- Available business hours
- Interpreter services available
- Follow-up documentation

3. INVESTIGATION PROCESS
- All reports taken seriously
- Prompt investigation initiated
- Confidentiality maintained
- Regular status updates
- Appropriate action taken

4. PROTECTION AGAINST RETALIATION
- No retaliation for good faith reports
- Whistleblower protections apply
- Anonymous reporting available
- Legal protections enforced

5. TYPES OF ISSUES TO REPORT
- Data privacy violations
- Discrimination or harassment
- Fraudulent activities
- Safety concerns
- Regulatory violations
- Ethical breaches

6. FOLLOW-UP
- Investigation results communicated
- Corrective actions implemented
- Policy updates as needed
- Training provided if required

Your reports help us maintain a safe, legal, and ethical platform for all users.

For urgent compliance issues, contact compliance@fieldforce.com immediately.
      ''',
    );
  }

  void _showLegalDocument(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Symbols.close),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
