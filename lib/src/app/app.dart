import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/auth/presentation/pages/login_page.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/home/presentation/pages/home_shell_page.dart';

class WiihApp extends StatelessWidget {
  const WiihApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WineList()),
      ],
      child: MaterialApp(
        title: 'WIIH',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFff0266),
            brightness: Brightness.light,
            primary: const Color(0xFFff0266),
            onPrimary: Colors.white,
            secondary: const Color(0xFFc2185b),
            onSecondary: Colors.white,
            surface: const Color(0xFFFDEEEF),
            primaryContainer: Colors.transparent,
            onSurface: Colors.black,
          ),
          scaffoldBackgroundColor: Colors.transparent,
          textTheme: _buildTextTheme(),
        ),
        home: const AuthenticatedApp(),
      ),
    );
  }
}

TextTheme _buildTextTheme() {
  final bodyTheme = GoogleFonts.montserratTextTheme();
  final headerTheme = GoogleFonts.loraTextTheme();

  return bodyTheme
      .copyWith(
        displayLarge: headerTheme.displayLarge,
        displayMedium: headerTheme.displayMedium,
        displaySmall: headerTheme.displaySmall,
        headlineLarge: headerTheme.headlineLarge,
        headlineMedium: headerTheme.headlineMedium,
        headlineSmall: headerTheme.headlineSmall,
        titleLarge: headerTheme.titleLarge,
        titleMedium: headerTheme.titleMedium,
        titleSmall: headerTheme.titleSmall,
      )
      .apply(
        bodyColor: Colors.black87,
        displayColor: Colors.black87,
      );
}

class AuthenticatedApp extends StatelessWidget {
  const AuthenticatedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const MyHomePage();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}
