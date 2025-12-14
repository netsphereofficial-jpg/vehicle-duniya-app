/// Firebase collection and storage path constants
/// Shared between admin panel and mobile app
class FirebaseConstants {
  FirebaseConstants._();

  // Collections
  static const String usersCollection = 'users';
  static const String adminsCollection = 'admins';
  static const String vehiclesCollection = 'vehicles';
  static const String propertiesCollection = 'properties';
  static const String carBazaarCollection = 'car_bazaar';
  static const String bidsCollection = 'bids';
  static const String auctionsCollection = 'auctions';
  static const String auctionAccessCollection = 'auction_access';
  static const String appConfigCollection = 'app_config';
  static const String categoriesCollection = 'categories';
  static const String kycDocumentsCollection = 'kyc_documents';
  static const String referralLinksCollection = 'referral_links';
  static const String suggestionsCollection = 'suggestions';
  static const String notificationsCollection = 'notifications';

  // Document IDs
  static const String settingsDoc = 'settings';

  // Storage Paths
  static const String vehiclesStorage = 'vehicles';
  static const String propertiesStorage = 'properties';
  static const String carBazaarStorage = 'car_bazaar';
  static const String usersProfileStorage = 'users/profiles';
  static const String propertyDocumentsStorage = 'properties/documents';
  static const String auctionsStorage = 'auctions';
  static const String bidReportsStorage = 'auctions/bid_reports';
  static const String imagesZipStorage = 'auctions/images_zip';
  static const String kycDocumentsStorage = 'kyc_documents';

  // Field Names
  static const String createdAtField = 'createdAt';
  static const String updatedAtField = 'updatedAt';
  static const String statusField = 'status';
  static const String isActiveField = 'isActive';
  static const String userIdField = 'userId';
  static const String auctionIdField = 'auctionId';
}
