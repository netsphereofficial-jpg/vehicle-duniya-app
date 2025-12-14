import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';

import 'config/routes.dart';
import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/services/notification_service.dart';
import 'core/utils/app_logger.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  AppLogger.info('Main', 'Firebase initialized');

  // Initialize dependencies
  await initDependencies();
  AppLogger.info('Main', 'Dependencies initialized');

  // Initialize notifications (after DI)
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();
  AppLogger.info('Main', 'Notification service initialized');

  runApp(const VehicleDuniyaApp());
}

class VehicleDuniyaApp extends StatefulWidget {
  const VehicleDuniyaApp({super.key});

  @override
  State<VehicleDuniyaApp> createState() => _VehicleDuniyaAppState();
}

class _VehicleDuniyaAppState extends State<VehicleDuniyaApp> {
  late final AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = getIt<AuthBloc>();
    // Check authentication status on app start
    _authBloc.add(const AuthCheckRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
      ],
      child: MaterialApp.router(
        title: 'Vehicle Duniya',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router(_authBloc),
      ),
    );
  }
}
