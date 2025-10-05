import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'app/data/models/loan.dart';
import 'app/routes/app_routes.dart';
import 'app/services/loan_service.dart';
import 'app/services/auth_service.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/web_config.dart';
import 'app/widgets/initialization_widget.dart';
import 'app/widgets/post_auth_initializer.dart';
import 'app/widgets/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive (still used for local persistence / offline cache)
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(PaymentAdapter());
  
  // Firebase only for web at this stage
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LoanService()),
      ],
      child: WebAppWrapper(
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'Installment Tracker',
            theme: WebConfig.isWeb 
                ? WebConfig.adjustThemeForWeb(AppTheme.lightTheme, context)
                : AppTheme.lightTheme,
            home: const AuthGate(
              child: PostAuthInitializer(
                child: InitializationWidget(),
              ),
            ),
            onGenerateRoute: AppRoutes.generateRoute,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
