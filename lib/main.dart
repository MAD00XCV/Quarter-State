import 'package:provider/provider.dart';
import 'package:dahab_app/screen/home/home_screen.dart';
import 'package:dahab_app/screen/login_register/login_screen.dart';
import 'package:dahab_app/screen/welcome_onboarding/onboarding1_screen.dart';
import 'package:dahab_app/screen/welcome_onboarding/onboarding2_screen.dart';
import 'package:dahab_app/screen/welcome_onboarding/onboarding3_screen.dart';
import 'package:dahab_app/screen/welcome_onboarding/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'theme_provider.dart'; 

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: themeProvider.themeMode,
      initialRoute: '/welcome',
      onGenerateRoute: (settings) {
        Widget page;
        switch (settings.name) {
          case '/welcome':
            page = const WelcomeScreen();
            break;
          case '/onboarding1':
            page = const Onboarding1Screen();
            break;
          case '/onboarding2':
            page = const Onboarding2Screen();
            break;
          case '/onboarding3':
            page = const Onboarding3Screen();
            break;
          case '/login':
            page = const LoginScreen();
            break;
            case '/register':
            page = const Onboarding1Screen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          default:
            page = const WelcomeScreen();
        }
        return MaterialPageRoute(builder: (_) => page);
      },
    );
  }
}
