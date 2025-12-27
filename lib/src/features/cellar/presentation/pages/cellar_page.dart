// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/cellar/data/wine_repository.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/cellar/domain/models/wine_options.dart';
import 'package:wiih/src/features/cellar/presentation/pages/add_wine_page.dart';
import 'package:wiih/src/features/cellar/presentation/pages/edit_wine_page.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/shared/widgets/placeholder_image.dart';

class CellarPage extends StatefulWidget {
  const CellarPage({super.key});

  @override
  _CellarPageState createState() => _CellarPageState();
}

class _CellarPageState extends State<CellarPage> {
  static const String _allFilterLabel = 'All';

  static const Map<String, Color> _typeColors = {
    'Red': Color(0xFFD32F2F),
    'White': Color(0xFFA5A05B),
    'Ros\u00E9': Color(0xFFE57373),
    'Sparkling': Color(0xFF80CBC4),
    'Orange': Color(0xFFF6A25C),
    'PetNat': Color(0xFF9C27B0),
  };

  Color _colorForType(ThemeData theme, String type) {
    return _typeColors[type] ?? theme.colorScheme.primary;
  }

  Color _onColor(Color base) {
    return base.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
  }

  Color _tintFor(Color base, ThemeData theme, [double opacity = 0.16]) {
    return Color.alphaBlend(
        base.withValues(alpha: opacity), theme.colorScheme.surface);
  }

  final TextEditingController _searchController = TextEditingController();
  late final WineList _wineList;

  String selectedSortOption = 'name';
  String selectedFilterOption = _allFilterLabel;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _wineList = Provider.of<WineList>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sortWines(selectedSortOption, persist: false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<WineList>(
      builder: (context, list, child) {
        final wines = _applySearch(list.wines);
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _CellarToolbarDelegate(
                height: 260,
                child: _buildToolbar(theme),
              ),
            ),
            if (wines.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(theme),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wine = wines[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == wines.length - 1 ? 0 : 12,
                        ),
                        child: _buildWineCard(context, wine),
                      );
                    },
                    childCount: wines.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    final surface = theme.colorScheme.surface.withValues(alpha: 0.95);
    final shadowColor = theme.colorScheme.primary.withValues(alpha: 0.08);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchTerm.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                          labelText: 'Search your cellar',
                          hintText: 'Name, winery, grape, country...',
                          filled: true,
                          fillColor: theme.colorScheme.surface.withValues(alpha: 0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () => _navigateToAddWinePage(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add wine'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildFilterChips(),
                const SizedBox(height: 16),
                _buildSortChips(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = <String>[_allFilterLabel, ...WineOptions.types];
    final theme = Theme.of(context);
    final defaultLabelColor = theme.textTheme.bodyMedium?.color;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: filters.map((type) {
          final isSelected = selectedFilterOption == type;
          final typeColor = type == _allFilterLabel
              ? theme.colorScheme.primary
              : _colorForType(theme, type);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                type == _allFilterLabel ? 'All types' : type,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? _onColor(typeColor) : defaultLabelColor,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _updateFilter(type),
              showCheckmark: isSelected,
              checkmarkColor: _onColor(typeColor),
              backgroundColor: _tintFor(typeColor, theme, 0.12),
              selectedColor: _tintFor(typeColor, theme, 0.28),
              side: BorderSide(
                color:
                    isSelected ? typeColor : theme.colorScheme.outlineVariant,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildSortChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: _sortOptions.map((option) {
          final isSelected = selectedSortOption == option.value;
          final color = theme.colorScheme.primary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => _onSortChanged(option.value),
              selectedColor: color.withValues(alpha: 0.18),
              backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.7),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
              side: BorderSide(
                color: isSelected ? color : theme.colorScheme.outlineVariant,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No wines match your filters.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting the search or add a new bottle to your cellar.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToAddWinePage(context),
              icon: const Icon(Icons.add),
              label: const Text('Add wine'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWineCard(BuildContext context, Wine wine) {
    final theme = Theme.of(context);
    final typeColor = _colorForType(theme, wine.type);
    final accentBackground = _tintFor(typeColor, theme, 0.18);
    final bottleLabel = wine.bottleCount == 1 ? 'bottle' : 'bottles';

    return Dismissible(
      key: Key(wine.id.toString()),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
        Icons.add,
        Alignment.centerLeft,
        Colors.greenAccent,
      ),
      secondaryBackground: _buildSwipeBackground(
        Icons.remove,
        Alignment.centerRight,
        Colors.redAccent,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _addBottle(wine);
        } else if (direction == DismissDirection.endToStart) {
          _removeBottle(wine);
        }
        await WineRepository.saveWines(_wineList);
        return false;
      },
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: typeColor.withValues(alpha: 0.28)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEditWinePage(context, wine),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWineImage(context, wine),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              '${wine.name} ${wine.year}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: accentBackground,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              wine.type,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            wine.winery,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Icon(
                            Icons.circle,
                            size: 4,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.6),
                          ),
                          Text(
                            wine.country,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      if (wine.grapeVariety.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          wine.grapeVariety,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.sell_outlined, size: 18, color: typeColor),
                          const SizedBox(width: 6),
                          Text(
                            '${wine.price} CHF',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: typeColor,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentBackground,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${wine.bottleCount} $bottleLabel',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: typeColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWineImage(BuildContext context, Wine wine) {
    final borderRadius = BorderRadius.circular(12);
    Widget child;

    if (wine.imageUrl != null && wine.imageUrl!.isNotEmpty) {
      child = Image.network(
        wine.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            PlaceholderImage(context: context, wine: wine),
      );
    } else {
      child = PlaceholderImage(context: context, wine: wine);
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: SizedBox(
          width: 90,
          height: 120,
          child: child,
        ),
      ),
    );
  }

  Widget _buildSwipeBackground(
    IconData icon,
    Alignment alignment,
    Color color,
  ) {
    return Container(
      alignment: alignment,
      color: color,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Icon(icon),
      ),
    );
  }

  void _addBottle(Wine wine) {
    setState(() => wine.bottleCount++);
  }

  void _removeBottle(Wine wine) {
    final originalBottleCount = wine.bottleCount;
    setState(() {
      wine.bottleCount--;
      if (wine.bottleCount <= 0) {
        _showDeleteConfirmationDialog(wine, originalBottleCount);
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog(
    Wine wine,
    int originalBottleCount,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Wine'),
          content: const Text('Are you sure you want to delete this wine?'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => wine.bottleCount = originalBottleCount);
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _deleteWine(wine);
                Navigator.pop(context, true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWine(Wine wine) {
    _wineList.deleteWine(wine.id);
    WineRepository.saveWines(_wineList);
  }

  void _onSortChanged(String? value) {
    if (value == null || value == selectedSortOption) {
      return;
    }
    setState(() => selectedSortOption = value);
    _sortWines(value);
  }

  void _sortWines(String option, {bool persist = true}) {
    switch (option) {
      case 'price':
        _wineList.sortWinesByPrice();
        break;
      case 'year':
        _wineList.sortWinesByYear();
        break;
      case 'type':
        _wineList.sortWinesByType();
        break;
      case 'country':
        _wineList.sortWinesByCountry();
        break;
      default:
        _wineList.sortWinesByName();
    }
    if (persist) {
      WineRepository.saveWines(_wineList);
    }
  }

  void _updateFilter(String type) {
    if (selectedFilterOption == type) {
      return;
    }
    setState(() => selectedFilterOption = type);

    if (type == _allFilterLabel) {
      _wineList.clearFilter();
    } else {
      _wineList.filterWinesByType(type);
    }
    _sortWines(selectedSortOption, persist: false);
  }

  void _onSearchChanged(String value) {
    setState(() => _searchTerm = value.trim());
  }

  List<Wine> _applySearch(List<Wine> wines) {
    if (_searchTerm.isEmpty) {
      return wines;
    }
    final query = _searchTerm.toLowerCase();
    return wines
        .where(
          (wine) =>
              wine.name.toLowerCase().contains(query) ||
              wine.winery.toLowerCase().contains(query) ||
              wine.country.toLowerCase().contains(query) ||
              wine.type.toLowerCase().contains(query) ||
              wine.grapeVariety.toLowerCase().contains(query),
        )
        .toList();
  }

  Future<void> _navigateToEditWinePage(BuildContext context, Wine wine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditWinePage(wine: wine)),
    );

    if (result != null && result is Wine) {
      _wineList.updateWine(result);
      await WineRepository.saveWines(_wineList);
    } else if (result == true) {
      _wineList.deleteWine(wine.id);
      await WineRepository.saveWines(_wineList);
    }
  }

  Future<void> _navigateToAddWinePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWinePage()),
    );

    if (result != null && result is Wine) {
      _wineList.addWine(result);
      await WineRepository.saveWines(_wineList);
    }
  }
}

class _CellarToolbarDelegate extends SliverPersistentHeaderDelegate {
  _CellarToolbarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _CellarToolbarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _SortOption {
  const _SortOption({required this.value, required this.label});

  final String value;
  final String label;
}

const List<_SortOption> _sortOptions = <_SortOption>[
  _SortOption(value: 'name', label: 'Name (A-Z)'),
  _SortOption(value: 'year', label: 'Year'),
  _SortOption(value: 'price', label: 'Price'),
  _SortOption(value: 'type', label: 'Type'),
  _SortOption(value: 'country', label: 'Country'),
];
