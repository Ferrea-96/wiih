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
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const double _railBreakpoint = 900;
  static const double _extendedRailBreakpoint = 1100;

  late Future<void> _initialLoad;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final wineList = Provider.of<WineList>(context, listen: false);
    final notesList = Provider.of<NotesList>(context, listen: false);

    await Future.wait([
      WineRepository.loadWines(wineList),
      NoteRepository.loadNotes(notesList),
    ]);
  }

  void _retryInitialLoad() {
    setState(() {
      _initialLoad = _loadInitialData();
    });
  }

  void _handleDestinationSelected(int index) {
    if (_selectedIndex == index) {
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useRail = constraints.maxWidth >= _railBreakpoint;
        final extendRail = constraints.maxWidth >= _extendedRailBreakpoint;

        return FutureBuilder<void>(
          future: _initialLoad,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState != ConnectionState.done;
            final hasError = snapshot.hasError;
            final body = () {
              if (isLoading) {
                return const Center(child: AnimatedWineBottleIcon());
              }
              if (hasError) {
                return _LoadingError(
                  message: snapshot.error?.toString(),
                  onRetry: _retryInitialLoad,
                );
              }
              return _buildPageContent();
            }();

            return useRail
                ? _buildWideScaffold(body, extendRail)
                : _buildCompactScaffold(body);
          },
        );
      },
    );
  }

  Widget _buildWideScaffold(Widget body, bool extended) {
    final navigationWidth = extended ? 276.0 : 92.0;
    final destinations = _navigationItems
        .map(
          (item) => NavigationRailDestination(
            icon: Icon(item.icon),
            label: Text(item.label),
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FA),
      body: Row(
        children: [
          Container(
            width: navigationWidth,
            color: const Color(0xFFFFF6FA),
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    extended: extended,
                    selectedIndex: _selectedIndex,
                    destinations: destinations,
                    onDestinationSelected: _handleDestinationSelected,
                  ),
                ),
                if (_selectedIndex == 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
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
              child: SafeArea(
                child: Container(
                  color: Colors.transparent,
                  child: body,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactScaffold(Widget body) {
    final destinations = _navigationItems
        .map(
          (item) => NavigationDestination(
            icon: Icon(item.icon),
            label: item.label,
          ),
        )
        .toList(growable: false);

    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FA),
      appBar: AppBar(
        title: Text(_navigationItems[_selectedIndex].label),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: AuthService.signOut,
                ),
              ]
            : null,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: body,
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _handleDestinationSelected,
        destinations: destinations,
        backgroundColor: Colors.white.withOpacity(0.8),
        indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
      ),
    );
  }

  Widget _buildPageContent() {
    switch (_selectedIndex) {
      case 0:
        return HomePage(
          onCellarTap: () => _handleDestinationSelected(1),
          onNotesTap: () => _handleDestinationSelected(3),
        );
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

class _LoadingError extends StatelessWidget {
  const _LoadingError({this.message, required this.onRetry});

  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'We could not refresh your cellar.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

const List<_NavigationItem> _navigationItems = <_NavigationItem>[
  _NavigationItem(icon: Icons.home, label: 'Home'),
  _NavigationItem(icon: Icons.wine_bar, label: 'Cellar'),
  _NavigationItem(icon: Icons.travel_explore, label: 'Countries'),
  _NavigationItem(icon: Icons.notes, label: 'Notes'),
];
