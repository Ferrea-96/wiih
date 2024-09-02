// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/animated_wine_bottle.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/notes_util.dart';
import 'package:wiih/classes/wines_util.dart';
import 'package:wiih/pages/cellar_page.dart';
import 'package:wiih/pages/home_page.dart';
import 'package:wiih/pages/notes_page.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

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
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WIIH',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0x00ff0266)),
      ),
      home: MyHomePage(isInitialLoading: true),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final bool isInitialLoading;

  const MyHomePage({Key? key, required this.isInitialLoading})
      : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;
  // ignore: unused_field
  late Future<void> _initialLoadFuture;
  late WineList wineList;
  late NotesList notesList;
  bool _isInitialLoading = true; // Flag to track initial loading

  @override
  void initState() {
    super.initState();
    wineList = Provider.of<WineList>(context, listen: false);
    notesList = Provider.of<NotesList>(context, listen: false);
    _initialLoadFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (widget.isInitialLoading) {
      await Future.delayed(Duration(seconds: 2));
    }
    await WinesUtil.loadWines(wineList);
    await NotesUtil.loadNotes(notesList);
    setState(() {
      _isInitialLoading =
          false; // Update flag after initial loading is completed
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.wine_bar),
                    label: Text('Cellar'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.notes),
                    label: Text('Notes'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: _buildPage(context),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPage(BuildContext context) {
    if (_isInitialLoading) {
      return Center(
        child: AnimatedWineBottleIcon(),
      );
    } else {
      // Display the appropriate page after initial loading is completed
      return _buildPageContent(context);
    }
  }

  Widget _buildPageContent(BuildContext context) {
    // Determine which page to show based on the selectedIndex
    switch (selectedIndex) {
      case 0:
        return HomePage();
      case 1:
        return CellarPage();
      case 2:
        return NotesPage();
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
  }
}
