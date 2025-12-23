import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/cellar/data/wine_repository.dart';
import 'package:wiih/src/features/cellar/presentation/pages/add_wine_page.dart';
import 'package:wiih/src/features/cellar/presentation/pages/cellar_page.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/countries/presentation/pages/country_page.dart';
import 'package:wiih/src/features/home/presentation/pages/home_page.dart';
import 'package:wiih/src/features/more/presentation/pages/more_page.dart';
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
  static const double _bottomNavHeight = 80;
  static const double _bottomNavBarHeight = 64;
  static const double _bottomNavOverlap = 16;
  static const double _bottomNavButtonSize = 70;
  static const double _bottomNavSidePadding = 10;
  static const double _bottomNavBottomPadding = 2;

  late Future<void> _initialLoad;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialLoad = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final wineList = Provider.of<WineList>(context, listen: false);

    await Future.wait([
      WineRepository.loadWines(wineList),
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

  void _handleAddWine() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddWinePage(),
      ),
    );
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
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6FA),
      appBar: AppBar(
        title: const Text('WIIH'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: GradientBackground(
        child: SafeArea(
          child: body,
        ),
      ),
      bottomNavigationBar: _FloatingBottomBar(
        selectedIndex: _selectedIndex,
        items: _navigationItems,
        onItemSelected: _handleDestinationSelected,
        onAddTap: _handleAddWine,
        barHeight: _bottomNavBarHeight,
        buttonSize: _bottomNavButtonSize,
        overlap: _bottomNavOverlap,
        sidePadding: _bottomNavSidePadding,
        bottomPadding: _bottomNavBottomPadding,
        height: _bottomNavHeight,
      ),
    );
  }

  Widget _buildPageContent() {
    return IndexedStack(
      index: _selectedIndex,
      children: [
        HomePage(
          onCellarTap: () => _handleDestinationSelected(1),
          onCountriesTap: () => _handleDestinationSelected(2),
        ),
        const CellarPage(),
        const CountryPage(),
        const MorePage(),
      ],
    );
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
  _NavigationItem(icon: Icons.home, label: 'Dashboard'),
  _NavigationItem(icon: Icons.wine_bar, label: 'Cellar'),
  _NavigationItem(icon: Icons.travel_explore, label: 'Countries'),
  _NavigationItem(icon: Icons.more_horiz, label: 'More'),
];

class _FloatingBottomBar extends StatelessWidget {
  const _FloatingBottomBar({
    required this.selectedIndex,
    required this.items,
    required this.onItemSelected,
    required this.onAddTap,
    required this.height,
    required this.barHeight,
    required this.buttonSize,
    required this.overlap,
    required this.sidePadding,
    required this.bottomPadding,
  });

  final int selectedIndex;
  final List<_NavigationItem> items;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onAddTap;
  final double height;
  final double barHeight;
  final double buttonSize;
  final double overlap;
  final double sidePadding;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).padding.bottom;
    final barBottomOffset = bottomInset + bottomPadding;
    final buttonBottomOffset =
        barBottomOffset + barHeight + overlap - buttonSize;

    return SafeArea(
      top: false,
      child: SizedBox(
        height: height + bottomInset,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  left: sidePadding,
                  right: sidePadding,
                  bottom: barBottomOffset,
                ),
                child: _BottomBarSurface(
                  height: barHeight,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomNavItem(
                          item: items[0],
                          selected: selectedIndex == 0,
                          onTap: () => onItemSelected(0),
                        ),
                      ),
                      Expanded(
                        child: _BottomNavItem(
                          item: items[1],
                          selected: selectedIndex == 1,
                          onTap: () => onItemSelected(1),
                        ),
                      ),
                      SizedBox(width: buttonSize),
                      Expanded(
                        child: _BottomNavItem(
                          item: items[2],
                          selected: selectedIndex == 2,
                          onTap: () => onItemSelected(2),
                        ),
                      ),
                      Expanded(
                        child: _BottomNavItem(
                          item: items[3],
                          selected: selectedIndex == 3,
                          onTap: () => onItemSelected(3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(bottom: buttonBottomOffset),
                child: _CenterAddButton(
                  diameter: buttonSize,
                  color: theme.colorScheme.primary,
                  onTap: onAddTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomBarSurface extends StatelessWidget {
  const _BottomBarSurface({required this.height, required this.child});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface.withOpacity(0.98),
      elevation: 8,
      shadowColor: Colors.black.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: height,
        child: child,
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurfaceVariant;

    return InkResponse(
      onTap: onTap,
      radius: 28,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              item.icon,
              color: color,
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 180),
              style: theme.textTheme.labelSmall!.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              child: Text(item.label),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterAddButton extends StatefulWidget {
  const _CenterAddButton({
    required this.diameter,
    required this.color,
    required this.onTap,
  });

  final double diameter;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_CenterAddButton> createState() => _CenterAddButtonState();
}

class _CenterAddButtonState extends State<_CenterAddButton> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) {
      return;
    }
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: widget.diameter,
          height: widget.diameter,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.16),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Icon(
            Icons.add,
            size: widget.diameter * 0.45,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}
