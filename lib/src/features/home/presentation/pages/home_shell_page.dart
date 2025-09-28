import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/auth/data/auth_service.dart';
import 'package:wiih/src/features/cellar/data/wine_repository.dart';
import 'package:wiih/src/features/cellar/presentation/pages/cellar_page.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/countries/presentation/pages/country_page.dart';
import 'package:wiih/src/features/home/presentation/pages/home_page.dart';
import 'package:wiih/src/features/notes/data/note_repository.dart';
import 'package:wiih/src/features/notes/presentation/pages/notes_page.dart';
import 'package:wiih/src/features/notes/presentation/state/notes_list.dart';
import 'package:wiih/src/shared/widgets/animated_wine_bottle.dart';
import 'package:wiih/src/shared/widgets/gradient_background.dart';

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
    await WineRepository.loadWines(wineList);
    await NoteRepository.loadNotes(notesList);
    if (!mounted) return;
    setState(() {
      _isInitialLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        backgroundColor: const Color(0xFFFDEEEF),
        body: Row(
          children: [
            Container(
              width: constraints.maxWidth >= 600 ? 272 : 72,
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
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: AuthService.signOut,
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
                      ? const Center(child: AnimatedWineBottleIcon())
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
