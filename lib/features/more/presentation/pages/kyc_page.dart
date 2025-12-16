import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class KycPage extends StatefulWidget {
  const KycPage({super.key});

  @override
  State<KycPage> createState() => _KycPageState();
}

class _KycPageState extends State<KycPage> {
  final _formKey = GlobalKey<FormState>();
  final _aadhaarController = TextEditingController();
  final _panController = TextEditingController();

  File? _aadhaarFront;
  File? _aadhaarBack;
  File? _panFront;

  String? _existingAadhaarFrontUrl;
  String? _existingAadhaarBackUrl;
  String? _existingPanFrontUrl;

  bool _isLoading = false;
  bool _isSubmitting = false;
  String _kycStatus = 'not_submitted';
  bool _isKycVerified = false;

  @override
  void initState() {
    super.initState();
    _loadKycData();
  }

  @override
  void dispose() {
    _aadhaarController.dispose();
    _panController.dispose();
    super.dispose();
  }

  Future<void> _loadKycData() async {
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      // Check user's KYC verification status
      final user = context.read<AuthBloc>().state.user;
      _isKycVerified = user?.isKycVerified ?? false;

      // Load existing KYC documents
      final kycDocs = await FirebaseFirestore.instance
          .collection('kyc_documents')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (kycDocs.docs.isNotEmpty) {
        final data = kycDocs.docs.first.data();
        setState(() {
          _aadhaarController.text = data['aadhaarNumber'] ?? '';
          _panController.text = data['panNumber'] ?? '';
          _existingAadhaarFrontUrl = data['aadhaarFrontUrl'];
          _existingAadhaarBackUrl = data['aadhaarBackUrl'];
          _existingPanFrontUrl = data['panFrontUrl'];
          _kycStatus = data['status'] ?? 'pending';
        });
      }
    } catch (e) {
      debugPrint('Error loading KYC data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(String type) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        switch (type) {
          case 'aadhaar_front':
            _aadhaarFront = File(pickedFile.path);
            break;
          case 'aadhaar_back':
            _aadhaarBack = File(pickedFile.path);
            break;
          case 'pan_front':
            _panFront = File(pickedFile.path);
            break;
        }
      });
    }
  }

  Future<String?> _uploadImage(File file, String path) async {
    try {
      final storageRef = FirebaseStorage.instance.ref().child(path);
      await storageRef.putFile(file);
      return await storageRef.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _submitKyc() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate images
    final hasAadhaarFront = _aadhaarFront != null || _existingAadhaarFrontUrl != null;
    final hasAadhaarBack = _aadhaarBack != null || _existingAadhaarBackUrl != null;
    final hasPanFront = _panFront != null || _existingPanFrontUrl != null;

    if (!hasAadhaarFront || !hasAadhaarBack) {
      _showError('Please upload both Aadhaar card images (front and back)');
      return;
    }

    if (!hasPanFront) {
      _showError('Please upload PAN card image');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        _showError('User not found. Please login again.');
        return;
      }

      // Upload new images
      String? aadhaarFrontUrl = _existingAadhaarFrontUrl;
      String? aadhaarBackUrl = _existingAadhaarBackUrl;
      String? panFrontUrl = _existingPanFrontUrl;

      if (_aadhaarFront != null) {
        aadhaarFrontUrl = await _uploadImage(
          _aadhaarFront!,
          'kyc/$userId/aadhaar_front.jpg',
        );
        if (aadhaarFrontUrl == null) {
          _showError('Failed to upload Aadhaar front image');
          return;
        }
      }

      if (_aadhaarBack != null) {
        aadhaarBackUrl = await _uploadImage(
          _aadhaarBack!,
          'kyc/$userId/aadhaar_back.jpg',
        );
        if (aadhaarBackUrl == null) {
          _showError('Failed to upload Aadhaar back image');
          return;
        }
      }

      if (_panFront != null) {
        panFrontUrl = await _uploadImage(
          _panFront!,
          'kyc/$userId/pan_front.jpg',
        );
        if (panFrontUrl == null) {
          _showError('Failed to upload PAN card image');
          return;
        }
      }

      // Check for existing KYC document
      final existingDocs = await FirebaseFirestore.instance
          .collection('kyc_documents')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      final kycData = {
        'userId': userId,
        'aadhaarNumber': _aadhaarController.text.trim(),
        'aadhaarFrontUrl': aadhaarFrontUrl,
        'aadhaarBackUrl': aadhaarBackUrl,
        'panNumber': _panController.text.trim().toUpperCase(),
        'panFrontUrl': panFrontUrl,
        'status': 'pending',
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (existingDocs.docs.isNotEmpty) {
        // Update existing document
        await existingDocs.docs.first.reference.update(kycData);
      } else {
        // Create new document
        kycData['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('kyc_documents').add(kycData);
      }

      if (mounted) {
        setState(() => _kycStatus = 'pending');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'KYC documents submitted successfully! Verification pending.',
              style: GoogleFonts.inter(),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error submitting KYC: $e');
      _showError('Failed to submit KYC. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
          'KYC Documents',
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // KYC Status Card
                    _buildStatusCard(),
                    const SizedBox(height: 20),

                    // Aadhaar Section
                    _buildSectionTitle('Aadhaar Card', Icons.credit_card_rounded),
                    const SizedBox(height: 12),
                    _buildDocumentCard(
                      children: [
                        _buildTextField(
                          controller: _aadhaarController,
                          label: 'Aadhaar Number',
                          hint: 'Enter 12-digit Aadhaar number',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          maxLength: 12,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter Aadhaar number';
                            }
                            if (value.length != 12) {
                              return 'Aadhaar number must be 12 digits';
                            }
                            return null;
                          },
                          enabled: !_isKycVerified,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildImageUpload(
                                title: 'Front Side',
                                file: _aadhaarFront,
                                existingUrl: _existingAadhaarFrontUrl,
                                onTap: _isKycVerified
                                    ? null
                                    : () => _pickImage('aadhaar_front'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildImageUpload(
                                title: 'Back Side',
                                file: _aadhaarBack,
                                existingUrl: _existingAadhaarBackUrl,
                                onTap: _isKycVerified
                                    ? null
                                    : () => _pickImage('aadhaar_back'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // PAN Section
                    _buildSectionTitle('PAN Card', Icons.badge_rounded),
                    const SizedBox(height: 12),
                    _buildDocumentCard(
                      children: [
                        _buildTextField(
                          controller: _panController,
                          label: 'PAN Number',
                          hint: 'Enter PAN number (e.g., ABCDE1234F)',
                          icon: Icons.badge_outlined,
                          maxLength: 10,
                          textCapitalization: TextCapitalization.characters,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter PAN number';
                            }
                            final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
                            if (!panRegex.hasMatch(value.toUpperCase())) {
                              return 'Enter valid PAN (e.g., ABCDE1234F)';
                            }
                            return null;
                          },
                          enabled: !_isKycVerified,
                        ),
                        const SizedBox(height: 16),
                        _buildImageUpload(
                          title: 'PAN Card Image',
                          file: _panFront,
                          existingUrl: _existingPanFrontUrl,
                          onTap: _isKycVerified
                              ? null
                              : () => _pickImage('pan_front'),
                          isFullWidth: true,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    if (!_isKycVerified)
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitKyc,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  _kycStatus == 'not_submitted'
                                      ? 'Submit KYC'
                                      : 'Update KYC',
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    const SizedBox(height: 16),

                    // Info Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.info.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.info,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Your documents will be verified within 24-48 hours. Please ensure all details are clearly visible in the uploaded images.',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: AppColors.info,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatusCard() {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (_isKycVerified) {
      statusColor = AppColors.success;
      statusText = 'Verified';
      statusIcon = Icons.verified_rounded;
    } else {
      switch (_kycStatus) {
        case 'pending':
          statusColor = AppColors.warning;
          statusText = 'Pending Verification';
          statusIcon = Icons.hourglass_empty_rounded;
          break;
        case 'rejected':
          statusColor = AppColors.error;
          statusText = 'Rejected';
          statusIcon = Icons.cancel_rounded;
          break;
        default:
          statusColor = AppColors.textSecondary;
          statusText = 'Not Submitted';
          statusIcon = Icons.pending_outlined;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(statusIcon, color: statusColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          validator: validator,
          enabled: enabled,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: enabled ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(
              fontSize: 15,
              color: AppColors.textHint,
            ),
            prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22),
            counterText: '',
            filled: true,
            fillColor: enabled ? AppColors.background : AppColors.border,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageUpload({
    required String title,
    required File? file,
    required String? existingUrl,
    required VoidCallback? onTap,
    bool isFullWidth = false,
  }) {
    final hasImage = file != null || (existingUrl != null && existingUrl.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: isFullWidth ? 150 : 100,
            decoration: BoxDecoration(
              color: hasImage ? null : AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasImage
                    ? AppColors.success.withValues(alpha: 0.5)
                    : AppColors.border,
                width: hasImage ? 2 : 1,
                style: hasImage ? BorderStyle.solid : BorderStyle.solid,
              ),
            ),
            child: hasImage
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        file != null
                            ? Image.file(file, fit: BoxFit.cover)
                            : Image.network(
                                existingUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _buildUploadPlaceholder(onTap != null),
                              ),
                        if (onTap != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.edit_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : _buildUploadPlaceholder(onTap != null),
          ),
        ),
      ],
    );
  }

  Widget _buildUploadPlaceholder(bool isEnabled) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEnabled ? Icons.add_photo_alternate_rounded : Icons.lock_rounded,
            color: isEnabled ? AppColors.textTertiary : AppColors.textHint,
            size: 28,
          ),
          const SizedBox(height: 4),
          Text(
            isEnabled ? 'Tap to upload' : 'Locked',
            style: GoogleFonts.inter(
              fontSize: 11,
              color: isEnabled ? AppColors.textTertiary : AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}
