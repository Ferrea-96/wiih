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
        return Column(
          children: [
            _buildControls(theme),
            Expanded(
              child: wines.isEmpty
                  ? _buildEmptyState(theme)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                      itemCount: wines.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildWineCard(context, wines[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  ),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _navigateToAddWinePage(context),
                icon: const Icon(Icons.add),
                label: const Text('Add wine'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedSortOption,
                    onChanged: _onSortChanged,
                    items: _sortOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label),
                          ),
                        )
                        .toList(growable: false),
                    icon: const Icon(Icons.keyboard_arrow_down),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = <String>[_allFilterLabel, ...WineOptions.types];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: filters
            .map(
              (type) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type == _allFilterLabel ? 'All types' : type),
                  selected: selectedFilterOption == type,
                  onSelected: (_) => _updateFilter(type),
                ),
              ),
            )
            .toList(growable: false),
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
        child: InkWell(
          onTap: () => _navigateToEditWinePage(context, wine),
          child: Row(
            children: [
              _buildWineImage(context, wine),
              Expanded(
                child: ListTile(
                  title: Text(
                    '${wine.name} ${wine.year}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${wine.type} - ${wine.winery} - ${wine.country}\n${wine.price} CHF',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      '${wine.bottleCount}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
