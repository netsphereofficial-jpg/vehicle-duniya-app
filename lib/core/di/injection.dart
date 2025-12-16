import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';

import '../network/network_info.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import '../services/realtime_firebase_service.dart';
import '../services/storage_service.dart';

// Repositories
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';

// BLoCs
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/vehicle_auction/presentation/bloc/vehicle_auction_bloc.dart';
import '../../features/property_auction/presentation/bloc/property_auction_bloc.dart';
import '../../features/car_bazaar/presentation/bloc/car_bazaar_bloc.dart';
import '../../features/bidding/presentation/bloc/bidding_bloc.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';

final getIt = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // External Services
  await _initExternalServices();

  // Core Services
  await _initCoreServices();

  // Repositories
  _initRepositories();

  // BLoCs
  _initBlocs();
}

Future<void> _initExternalServices() async {
  // Storage Service (SharedPreferences)
  final storageService = StorageService();
  await storageService.initialize();
  getIt.registerSingleton<StorageService>(storageService);
}

Future<void> _initCoreServices() async {
  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Firebase Services
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  // Firebase Service (wrapper)
  getIt.registerLazySingleton<FirebaseService>(
    () => FirebaseService(
      firestore: getIt<FirebaseFirestore>(),
      auth: getIt<FirebaseAuth>(),
      storage: getIt<FirebaseStorage>(),
    ),
  );

  // Real-time Firebase Service (optimized for streams & caching)
  getIt.registerLazySingleton<RealtimeFirebaseService>(
    () => RealtimeFirebaseService(
      firestore: getIt<FirebaseFirestore>(),
    ),
  );

  // Notification Service
  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
}

void _initRepositories() {
  // Auth Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      firebaseAuth: getIt<FirebaseAuth>(),
      firestore: getIt<FirebaseFirestore>(),
      storageService: getIt<StorageService>(),
    ),
  );
}

void _initBlocs() {
  // Auth BLoC (Singleton - global)
  getIt.registerSingleton<AuthBloc>(
    AuthBloc(authRepository: getIt<AuthRepository>()),
  );

  // Home BLoC (Factory) - Uses RealtimeFirebaseService for real-time streams
  getIt.registerFactory<HomeBloc>(
    () => HomeBloc(realtimeService: getIt<RealtimeFirebaseService>()),
  );

  // Vehicle Auction BLoC (Factory) - Uses RealtimeFirebaseService for live auctions
  getIt.registerFactory<VehicleAuctionBloc>(
    () => VehicleAuctionBloc(
      firebaseService: getIt<FirebaseService>(),
      realtimeService: getIt<RealtimeFirebaseService>(),
    ),
  );

  // Property Auction BLoC (Factory)
  getIt.registerFactory<PropertyAuctionBloc>(
    () => PropertyAuctionBloc(firebaseService: getIt<FirebaseService>()),
  );

  // Car Bazaar BLoC (Factory)
  getIt.registerFactory<CarBazaarBloc>(
    () => CarBazaarBloc(firebaseService: getIt<FirebaseService>()),
  );

  // Bidding BLoC (Factory)
  getIt.registerFactory<BiddingBloc>(
    () => BiddingBloc(firebaseService: getIt<FirebaseService>()),
  );

  // Profile BLoC (Factory)
  getIt.registerFactory<ProfileBloc>(
    () => ProfileBloc(
      firebaseService: getIt<FirebaseService>(),
      storageService: getIt<StorageService>(),
    ),
  );
}
