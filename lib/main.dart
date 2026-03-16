import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/conference_provider.dart';
import 'screens/splash_screen.dart';
import 'widgets/app_theme.dart';

void main() {
  runApp(const VidyenApp());
}

class VidyenApp extends StatelessWidget {
  const VidyenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConferenceProvider()),
      ],
      child: MaterialApp(
        title: 'VIDYEN Conference',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const SplashScreen(),
      ),
    );
  }
}
