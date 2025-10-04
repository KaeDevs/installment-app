import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app/data/models/loan.dart';
import 'app/routes/app_routes.dart';
import 'app/services/loan_service.dart';
import 'app/theme/app_theme.dart';
import 'app/utils/web_config.dart';
import 'app/widgets/initialization_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive adapters
  Hive.registerAdapter(LoanAdapter());
  Hive.registerAdapter(PaymentAdapter());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => LoanService(),
        ),
      ],
      child: WebAppWrapper(
        child: Builder(
          builder: (context) => MaterialApp(
            title: 'Installment Tracker',
            theme: WebConfig.isWeb 
                ? WebConfig.adjustThemeForWeb(AppTheme.lightTheme, context)
                : AppTheme.lightTheme,
            home: const InitializationWidget(),
            onGenerateRoute: AppRoutes.generateRoute,
            debugShowCheckedModeBanner: false,
          ),
        ),
      ),
    );
  }
}
