import 'package:equatable/equatable.dart';

/// Social link entity
class SocialLink extends Equatable {
  final String url;
  final bool enabled;

  const SocialLink({
    required this.url,
    this.enabled = true,
  });

  bool get isActive => enabled && url.isNotEmpty;

  SocialLink copyWith({
    String? url,
    bool? enabled,
  }) {
    return SocialLink(
      url: url ?? this.url,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  List<Object?> get props => [url, enabled];
}

/// Social links collection
class SocialLinks extends Equatable {
  final SocialLink facebook;
  final SocialLink twitter;
  final SocialLink instagram;
  final SocialLink youtube;
  final SocialLink linkedin;
  final SocialLink whatsapp;

  const SocialLinks({
    this.facebook = const SocialLink(url: ''),
    this.twitter = const SocialLink(url: ''),
    this.instagram = const SocialLink(url: ''),
    this.youtube = const SocialLink(url: ''),
    this.linkedin = const SocialLink(url: ''),
    this.whatsapp = const SocialLink(url: ''),
  });

  List<MapEntry<String, SocialLink>> get enabledLinks {
    final links = <MapEntry<String, SocialLink>>[];
    if (facebook.isActive) links.add(MapEntry('facebook', facebook));
    if (twitter.isActive) links.add(MapEntry('twitter', twitter));
    if (instagram.isActive) links.add(MapEntry('instagram', instagram));
    if (youtube.isActive) links.add(MapEntry('youtube', youtube));
    if (linkedin.isActive) links.add(MapEntry('linkedin', linkedin));
    if (whatsapp.isActive) links.add(MapEntry('whatsapp', whatsapp));
    return links;
  }

  SocialLinks copyWith({
    SocialLink? facebook,
    SocialLink? twitter,
    SocialLink? instagram,
    SocialLink? youtube,
    SocialLink? linkedin,
    SocialLink? whatsapp,
  }) {
    return SocialLinks(
      facebook: facebook ?? this.facebook,
      twitter: twitter ?? this.twitter,
      instagram: instagram ?? this.instagram,
      youtube: youtube ?? this.youtube,
      linkedin: linkedin ?? this.linkedin,
      whatsapp: whatsapp ?? this.whatsapp,
    );
  }

  @override
  List<Object?> get props => [
        facebook,
        twitter,
        instagram,
        youtube,
        linkedin,
        whatsapp,
      ];
}

/// App settings entity
class AppSettings extends Equatable {
  // Contact Info
  final String? officeAddress;
  final String? phone;
  final String? email;
  final String? fax;

  // Content
  final String? aboutUs;
  final String? biddingTerms;

  // Payment
  final bool paymentPageEnabled;
  final String? paymentQrCodeUrl;

  // App Version
  final String? appVersion;
  final String? minAppVersion;
  final bool forceUpdate;

  // Social Links
  final SocialLinks socialLinks;

  final DateTime? updatedAt;

  const AppSettings({
    this.officeAddress,
    this.phone,
    this.email,
    this.fax,
    this.aboutUs,
    this.biddingTerms,
    this.paymentPageEnabled = false,
    this.paymentQrCodeUrl,
    this.appVersion,
    this.minAppVersion,
    this.forceUpdate = false,
    this.socialLinks = const SocialLinks(),
    this.updatedAt,
  });

  bool get hasContactInfo =>
      phone != null || email != null || officeAddress != null;

  bool get hasPaymentQr =>
      paymentPageEnabled && paymentQrCodeUrl != null && paymentQrCodeUrl!.isNotEmpty;

  AppSettings copyWith({
    String? officeAddress,
    String? phone,
    String? email,
    String? fax,
    String? aboutUs,
    String? biddingTerms,
    bool? paymentPageEnabled,
    String? paymentQrCodeUrl,
    String? appVersion,
    String? minAppVersion,
    bool? forceUpdate,
    SocialLinks? socialLinks,
    DateTime? updatedAt,
  }) {
    return AppSettings(
      officeAddress: officeAddress ?? this.officeAddress,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fax: fax ?? this.fax,
      aboutUs: aboutUs ?? this.aboutUs,
      biddingTerms: biddingTerms ?? this.biddingTerms,
      paymentPageEnabled: paymentPageEnabled ?? this.paymentPageEnabled,
      paymentQrCodeUrl: paymentQrCodeUrl ?? this.paymentQrCodeUrl,
      appVersion: appVersion ?? this.appVersion,
      minAppVersion: minAppVersion ?? this.minAppVersion,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      socialLinks: socialLinks ?? this.socialLinks,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        officeAddress,
        phone,
        email,
        fax,
        aboutUs,
        biddingTerms,
        paymentPageEnabled,
        paymentQrCodeUrl,
        appVersion,
        minAppVersion,
        forceUpdate,
        socialLinks,
        updatedAt,
      ];
}
