import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/gradient_background.dart';
import 'package:wiih/flutter/auth_service.dart';
import 'package:wiih/flutter/firebase_options.dart';
import 'package:wiih/pages/login_page.dart';
import 'package:wiih/pages/home_page.dart';
import 'package:wiih/pages/country_page.dart';
import 'package:wiih/pages/cellar_page.dart';
import 'package:wiih/pages/notes_page.dart';
import 'package:wiih/classes/animated_wine_bottle.dart';
import 'package:wiih/classes/notes_util.dart';
import 'package:wiih/classes/wines_util.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WineList()),
        ChangeNotifierProvider(create: (_) => NotesList()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        textTheme: GoogleFonts.playfairDisplayTextTheme().apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      home: const AuthenticatedApp(),
    );
  }
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
          return const MyHomePage(isInitialLoading: true);
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isInitialLoading;

  const MyHomePage({super.key, required this.isInitialLoading});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  late WineList wineList;
  late NotesList notesList;
  bool _isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    wineList = Provider.of<WineList>(context, listen: false);
    notesList = Provider.of<NotesList>(context, listen: false);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.isInitialLoading) {
      await Future.delayed(const Duration(seconds: 2));
    }
    await WinesUtil.loadWines(wineList);
    await NotesUtil.loadNotes(notesList);
    setState(() {
      _isInitialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: const Color(0xFFFDEEEF), // for the whole base
        body: Row(
          children: [
            // ✅ Fixed white left side
            Container(
              width: constraints.maxWidth >= 600 ? 72 + 200 : 72,
              color: const Color(0xFFFDEEEF),
              child: Column(
                children: [
                  Expanded(
                    child: NavigationRail(
                      extended: constraints.maxWidth >= 600,
                      destinations: const [
                        NavigationRailDestination(
                          icon: Icon(Icons.home),
                          label: Text('Home'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.wine_bar),
                          label: Text('Cellar'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.travel_explore),
                          label: Text('Countries'),
                        ),
                        NavigationRailDestination(
                          icon: Icon(Icons.notes),
                          label: Text('Notes'),
                        ),
                      ],
                      selectedIndex: selectedIndex,
                      onDestinationSelected: (index) {
                        setState(() => selectedIndex = index);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: Column(
                      children: [
                        IconButton(
                            icon: const Icon(Icons.logout),
                            onPressed: AuthService.signOut),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GradientBackground(
                child: Container(
                  color: Colors.transparent,
                  child: _isInitialLoading
                      ? Center(child: AnimatedWineBottleIcon())
                      : _buildPageContent(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (selectedIndex) {
      case 0:
        return const HomePage();
      case 1:
        return const CellarPage();
      case 2:
        return const CountryPage();
      case 3:
        return const NotesPage();
      default:
        return const Center(child: Text('Unknown Page'));
    }
  }
}
