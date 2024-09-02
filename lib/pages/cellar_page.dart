// ignore_for_file: library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/classes/change_notifier.dart';
import 'package:wiih/classes/wine.dart';
import 'package:wiih/classes/wines_util.dart';
import 'package:wiih/pages/add_wine_page.dart';
import 'package:wiih/pages/edit_wine_page.dart';

class CellarPage extends StatefulWidget {
  const CellarPage({super.key});

  @override
  _CellarPageState createState() => _CellarPageState();
}

class _CellarPageState extends State<CellarPage> {
  late WineList wineList; // Declare wineList as an instance variable
  String selectedSortOption = 'None';

  @override
  void initState() {
    super.initState();
    // Initialize wineList in the initState method
    wineList = Provider.of<WineList>(context, listen: false);
    WinesUtil.loadWines;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Consumer<WineList>(
            builder: (context, wineList, child) {
              return Expanded(
                child: ListView.builder(
                  itemCount: wineList.wines.length,
                  itemBuilder: (context, index) {
                    return _buildWineCard(context, wineList.wines[index]);
                  },
                ),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    _navigateToAddWinePage(context);
                  },
                  child: const Icon(Icons.add),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  onPressed: () {
                    _showSortOptions(context);
                  },
                  child: const Text('Sort'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWineCard(BuildContext context, Wine wine) {
    return Dismissible(
      key: Key(wine.id.toString()),
      direction: DismissDirection.horizontal,
      background: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.greenAccent,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(left: 20.0),
          child: const Icon(Icons.add),
        ),
      ),
      secondaryBackground: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          color: Colors.redAccent,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20.0),
          child: const Icon(Icons.remove),
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Handle add bottle
          _addBottle(wine);
          WinesUtil.saveWines(wineList);
          return false; // Do not dismiss
        } else if (direction == DismissDirection.endToStart) {
          // Handle remove bottle
          _removeBottle(wine);
          WinesUtil.saveWines(wineList);
          return false; // Do not dismiss
        }
        return false;
      },
      child: Card(
        child: InkWell(
          onTap: () {
            _navigateToEditWinePage(context, wine);
          },
          child: Row(
            children: [
              // Display wine image on the left side
              SizedBox(
                width: 80, // Adjust the width as needed
                height: 100, // Adjust the height as needed
                // You can use other shapes as well
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  child: wine.imageUrl != null
                      ? Image.network(
                          wine.imageUrl!,
                          fit: BoxFit.cover,
                        )
                      : _placeholderImage(context, wine),
                ),
              ),
              // Display wine details in a ListTile
              Expanded(
                child: ListTile(
                  title: Text('${wine.name} ${wine.year}'),
                  subtitle: Text(
                    '${wine.type} - ${wine.winery} - ${wine.country}\n${wine.price} CHF',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .secondaryContainer, // You can change the highlight color
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

  void _addBottle(Wine wine) {
    setState(() {
      wine.bottleCount++;
    });
  }

  void _removeBottle(Wine wine) {
    setState(() {
      wine.bottleCount--;

      if (wine.bottleCount <= 0) {
        // Show confirmation dialog to delete the wine
        _showDeleteConfirmationDialog(wine);
      }
    });
  }

  Future<void> _showDeleteConfirmationDialog(Wine wine) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Wine'),
          content: const Text('Are you sure you want to delete this wine?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false); // Keep the wine
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Perform wine deletion
                _deleteWine(wine);
                Navigator.pop(context, true); // Confirm deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteWine(Wine wine) {
    setState(() {
      wineList.deleteWine(wine.id);
      WinesUtil.saveWines(wineList);
    });
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
      case 'None':
        wineList.sortWinesByName();
        break;
    }
    WinesUtil.saveWines;
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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

  Widget _buildSortOption(String option) {
    return ListTile(
      title: Text(option),
      onTap: () {
        setState(() {
          selectedSortOption = option;
          _sortWines();
        });
        Navigator.pop(context);
      },
    );
  }

  void _navigateToEditWinePage(BuildContext context, Wine wine) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditWinePage(wine: wine)),
    );

    if (result != null && result is Wine) {
      wineList.updateWine(result); // Use the WineList to update the wine
      await WinesUtil.saveWines(wineList); // Wait for the wines to be saved
    } else if (result != null && result is bool && result) {
      wineList.deleteWine(wine.id); // Use the WineList to delete the wine
      await WinesUtil.saveWines(wineList); // Wait for the wines to be saved
    }
  }

  void _navigateToAddWinePage(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddWinePage()),
    );

    if (result != null && result is Wine) {
      wineList.addWine(result); // Use the WineList to add the wine
      WinesUtil.saveWines(wineList);
    }
  }

  Widget _placeholderImage(BuildContext context, Wine wine) {
    switch (wine.type) {
      case 'Red':
        return Image.asset(
          'assets/placeholder_red_image.jpg',
          fit: BoxFit.fill,
        );
      case 'White':
        return Image.asset(
          'assets/placeholder_white_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Rosé':
        return Image.asset(
          'assets/placeholder_rose_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Sparkling':
        return Image.asset(
          'assets/placeholder_sparkling_image.jpg',
          fit: BoxFit.fill,
        );
      case 'Orange':
        return Image.asset(
          'assets/placeholder_orange_image.jpg',
          fit: BoxFit.fill,
        );
      default:
        return Image.asset(
          'assets/placeholder_red_image.jpg', // Default placeholder image
          fit: BoxFit.fill,
        );
    }
  }
}
