import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:wiih/classes/change_notifier.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WIIH',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFff0266),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.playfairDisplayTextTheme().apply(
          bodyColor: Colors.black,
          displayColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFff0266),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.playfairDisplayTextTheme().apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthenticatedApp(
        isDarkMode: _isDarkMode,
        onThemeToggle: (val) => setState(() => _isDarkMode = val),
      ),
    );
  }
}

class AuthenticatedApp extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeToggle;

  const AuthenticatedApp(
      {super.key, required this.isDarkMode, required this.onThemeToggle});

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
          return MyHomePage(
            isInitialLoading: true,
            onThemeToggle: onThemeToggle,
          );
        } else {
          return const LoginPage();
        }
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isInitialLoading;
  final ValueChanged<bool> onThemeToggle;

  const MyHomePage(
      {Key? key, required this.isInitialLoading, required this.onThemeToggle})
      : super(key: key);

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
        body: Row(
          children: [
            SafeArea(
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
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                        icon: Icon(Icons.logout),
                        onPressed: (AuthService.signOut)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: IconButton(
                      icon: Icon(
                        Theme.of(context).brightness == Brightness.dark
                            ? Icons.wb_sunny
                            : Icons.nights_stay,
                      ),
                      onPressed: () {
                        widget.onThemeToggle(
                          Theme.of(context).brightness != Brightness.dark,
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _isInitialLoading
                    ? Center(child: AnimatedWineBottleIcon())
                    : _buildPageContent(),
              ),
            )
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
