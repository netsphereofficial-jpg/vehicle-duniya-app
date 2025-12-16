import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/constants/app_colors.dart';

enum PolicyType { privacy, terms, refund }

class PolicyPage extends StatefulWidget {
  final String title;
  final PolicyType policyType;

  const PolicyPage({
    super.key,
    required this.title,
    required this.policyType,
  });

  @override
  State<PolicyPage> createState() => _PolicyPageState();
}

class _PolicyPageState extends State<PolicyPage> {
  bool _isLoading = true;
  String _policyContent = '';

  @override
  void initState() {
    super.initState();
    _loadPolicyContent();
  }

  Future<void> _loadPolicyContent() async {
    setState(() => _isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance
          .collection('settings')
          .doc('app_config')
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        String fieldName;
        switch (widget.policyType) {
          case PolicyType.privacy:
            fieldName = 'privacyPolicy';
            break;
          case PolicyType.terms:
            fieldName = 'termsConditions';
            break;
          case PolicyType.refund:
            fieldName = 'refundPolicy';
            break;
        }

        setState(() {
          _policyContent = data[fieldName] ?? _getDefaultContent();
        });
      } else {
        setState(() {
          _policyContent = _getDefaultContent();
        });
      }
    } catch (e) {
      debugPrint('Error loading policy content: $e');
      setState(() {
        _policyContent = _getDefaultContent();
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getDefaultContent() {
    switch (widget.policyType) {
      case PolicyType.privacy:
        return '''
Privacy Policy

Last updated: December 2024

1. Information We Collect
We collect information you provide directly to us, including personal information such as your name, email address, phone number, and any other information you choose to provide.

2. How We Use Your Information
We use the information we collect to:
- Provide, maintain, and improve our services
- Process transactions and send related information
- Send promotional communications (with your consent)
- Respond to your comments and questions

3. Information Sharing
We do not share your personal information with third parties except as described in this policy or with your consent.

4. Data Security
We implement appropriate security measures to protect your personal information against unauthorized access, alteration, disclosure, or destruction.

5. Your Rights
You have the right to access, update, or delete your personal information at any time through your account settings.

6. Contact Us
If you have any questions about this Privacy Policy, please contact us at support@vehicleduniya.com.
''';
      case PolicyType.terms:
        return '''
Terms & Conditions

Last updated: December 2024

1. Acceptance of Terms
By accessing and using Vehicle Duniya, you accept and agree to be bound by these Terms and Conditions.

2. Use of Service
- You must be at least 18 years old to use our services
- You are responsible for maintaining the confidentiality of your account
- You agree to provide accurate and complete information

3. Auction Rules
- All bids are legally binding
- The highest bidder at the close of the auction wins
- Payment must be completed within the specified timeframe
- Failure to complete payment may result in account suspension

4. Fees and Payments
- Service fees may apply to certain transactions
- All fees are clearly displayed before confirmation
- Refunds are subject to our Refund Policy

5. Prohibited Activities
You agree not to:
- Violate any applicable laws or regulations
- Interfere with the proper functioning of our services
- Submit false or misleading information

6. Limitation of Liability
Vehicle Duniya shall not be liable for any indirect, incidental, or consequential damages arising from your use of our services.

7. Changes to Terms
We reserve the right to modify these terms at any time. Continued use of our services constitutes acceptance of updated terms.
''';
      case PolicyType.refund:
        return '''
Refund Policy

Last updated: December 2024

1. General Policy
We strive to ensure a fair and transparent auction process. Refunds are available under specific circumstances as outlined below.

2. Eligible Refunds
Refunds may be issued in the following cases:
- Technical errors preventing successful bidding
- Duplicate charges due to system errors
- Vehicle/property significantly misrepresented

3. Non-Refundable Items
The following are non-refundable:
- Registration and membership fees
- Service fees for completed auctions
- Deposits forfeited due to non-payment

4. Refund Process
To request a refund:
1. Contact our support team within 7 days
2. Provide transaction details and reason for refund
3. Allow 5-7 business days for review
4. Approved refunds processed within 10 business days

5. Refund Methods
Refunds will be credited to the original payment method used for the transaction.

6. Disputes
For any disputes, please contact our support team at support@vehicleduniya.com. We aim to resolve all issues within 14 business days.

7. Contact Information
Email: support@vehicleduniya.com
Phone: +91 9876543210
''';
    }
  }

  IconData _getPolicyIcon() {
    switch (widget.policyType) {
      case PolicyType.privacy:
        return Icons.privacy_tip_rounded;
      case PolicyType.terms:
        return Icons.description_rounded;
      case PolicyType.refund:
        return Icons.currency_rupee_rounded;
    }
  }

  Color _getPolicyColor() {
    switch (widget.policyType) {
      case PolicyType.privacy:
        return AppColors.info;
      case PolicyType.terms:
        return AppColors.primary;
      case PolicyType.refund:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.title,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: _getPolicyColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getPolicyColor().withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _getPolicyColor().withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getPolicyIcon(),
                            color: _getPolicyColor(),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _getPolicyColor(),
                                ),
                              ),
                              Text(
                                'Please read carefully',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Policy Content
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: SelectableText(
                      _policyContent,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Footer
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.infoLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.info,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'For any questions regarding this policy, please contact our support team.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.info,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}
