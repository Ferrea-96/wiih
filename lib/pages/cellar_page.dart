// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/placeholder_image.dart';
import 'package:wiih/classes/wine/wine.dart';
import 'package:wiih/classes/wines_util.dart';
import 'package:wiih/pages/add_wine_page.dart';
import 'package:wiih/pages/edit_wine_page.dart';

class CellarPage extends StatefulWidget {
  const CellarPage({super.key});

  @override
  _CellarPageState createState() => _CellarPageState();
}

class _CellarPageState extends State<CellarPage> {
  late WineList wineList;
  String selectedSortOption = 'None';
  String selectedFilterOption = 'None';

  @override
  void initState() {
    super.initState();
    wineList = Provider.of<WineList>(context, listen: false);
    WinesUtil.loadWines(wineList);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Expanded(
            child: Consumer<WineList>(
              builder: (context, wineList, child) {
                return ListView.builder(
                  itemCount: wineList.wines.length,
                  itemBuilder: (context, index) {
                    return _buildWineCard(context, wineList.wines[index]);
                  },
                );
              },
            ),
          ),
          _buildBottomRow(context),
        ],
      ),
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15,15,15,25),
          child: ElevatedButton(
            onPressed: () => _navigateToAddWinePage(context),
            child: const Text('Add'),
          ),
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(15,15,15,25),
            child: ElevatedButton(
                onPressed: () => _showFilterOptions(context),
                child: const Text('Filter'))),
        Padding(
          padding: const EdgeInsets.fromLTRB(15,15,15,25),
          child: ElevatedButton(
            onPressed: () => _showSortOptions(context),
            child: const Text('Sort'),
          ),
        ),
      ],
    );
  }

  Widget _buildWineCard(BuildContext context, Wine wine) {
    return Dismissible(
      key: Key(wine.id.toString()),
      direction: DismissDirection.horizontal,
      background: _buildSwipeBackground(
          Icons.add, Alignment.centerLeft, Colors.greenAccent),
      secondaryBackground: _buildSwipeBackground(
          Icons.remove, Alignment.centerRight, Colors.redAccent),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          _addBottle(wine);
        } else if (direction == DismissDirection.endToStart) {
          _removeBottle(wine);
        }
        await WinesUtil.saveWines(wineList);
        return false;
      },
      child: Card(
        child: InkWell(
          onTap: () => _navigateToEditWinePage(context, wine),
          child: Row(
            children: [
              _buildWineImage(wine),
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

  Widget _buildWineImage(Wine wine) {
    return SizedBox(
      width: 80,
      height: 100,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(8.0)),
        child: wine.imageUrl != null
            ? Image.network(wine.imageUrl!, fit: BoxFit.contain)
            : PlaceholderImage(context: context, wine: wine),
      ),
    );
  }

  Widget _buildSwipeBackground(
      IconData icon, Alignment alignment, Color color) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        color: color,
        alignment: alignment,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
      Wine wine, int originalBottleCount) async {
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
    wineList.deleteWine(wine.id);
    WinesUtil.saveWines(wineList);
  }

  void _sortWines() {
    switch (selectedSortOption) {
      case 'Price':
        wineList.sortWinesByPrice();
        break;
      case 'Year':
        wineList.sortWinesByYear();
        break;
      case 'Type':
        wineList.sortWinesByType();
        break;
      case 'Country':
        wineList.sortWinesByCountry();
        break;
      default:
        wineList.sortWinesByName();
    }
    WinesUtil.saveWines(wineList);
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSortOption('None'),
              _buildSortOption('Type'),
              _buildSortOption('Country'),
              _buildSortOption('Year'),
              _buildSortOption('Price'),
            ],
          ),
        );
      },
    );
  }

  _buildSortOption(String option) {
    return RadioListTile<String>(
      value: option,
      groupValue: selectedSortOption,
      onChanged: (value) {
        if (value != null) {
          selectedSortOption = value;
          _sortWines();
          Navigator.pop(context);
        }
      },
      title: Text(option),
    );
  }

  void _filterWines() {
    switch (selectedFilterOption) {
      case 'Red':
        wineList.filterWinesByType('Red');
        break;
      case 'White':
        wineList.filterWinesByType('White');
        break;
      case 'Orange':
        wineList.filterWinesByType('Orange');
        break;
      case 'Ros\\u00E9':
        wineList.filterWinesByType('Ros\\u00E9');
        break;
      case 'Sparkling':
        wineList.filterWinesByType('Sparkling');
        break;
      case 'None':
        wineList.clearFilter();
        break;
      default:
        wineList.clearFilter();
    }
    WinesUtil.saveWines(wineList);
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterOption('None'),
              _buildFilterOption('Red'),
              _buildFilterOption('White'),
              _buildFilterOption('Orange'),
              _buildFilterOption('Ros\\u00E9'),
              _buildFilterOption('Sparkling'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String filterOption) {
    return RadioListTile<String>(
      value: filterOption,
      groupValue: selectedFilterOption,
      onChanged: (value) {
        if (value != null) {
          selectedFilterOption = value;
          _filterWines();
          _sortWines();
          Navigator.pop(context);
        }
      },
      title: Text(filterOption),
    );
  }

  Future<void> _navigateToEditWinePage(BuildContext context, Wine wine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditWinePage(wine: wine)),
    );

    if (result != null && result is Wine) {
      wineList.updateWine(result);
      await WinesUtil.saveWines(wineList);
    } else if (result == true) {
      wineList.deleteWine(wine.id);
      await WinesUtil.saveWines(wineList);
    }
  }

  Future<void> _navigateToAddWinePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWinePage()),
    );

    if (result != null && result is Wine) {
      wineList.addWine(result);
      await WinesUtil.saveWines(wineList);
    }
  }
}


