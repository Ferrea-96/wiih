import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/auth/data/auth_service.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.onCellarTap, this.onCountriesTap});

  final VoidCallback? onCellarTap;
  final VoidCallback? onCountriesTap;

  @override
  Widget build(BuildContext context) {
    return homeScreen(context);
  }

  Widget homeScreen(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            welcomeText(context),
            cellarStatistics(context),
            priceStatistics(context),
            countryStatistics(context),
          ],
        ),
      ),
    );
  }

  Widget welcomeText(BuildContext context) {
    final displayName = _resolveDisplayName();
    final greeting =
        displayName == null ? 'Hi there!' : 'Hi there, $displayName!';
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Text(
        greeting,
        style: theme.textTheme.headlineSmall?.copyWith(
          letterSpacing: 2,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget cellarStatistics(BuildContext context) {
    return Consumer<WineList>(
      builder: (context, wineList, child) {
        final wineCount = calculateSumOfWines(wineList.allWines);
        return _statisticCard(
          value: '$wineCount',
          label: 'wines in your cellar',
          onTap: onCellarTap,
          context: context,
        );
      },
    );
  }

  Widget priceStatistics(BuildContext context) {
    return Consumer<WineList>(
      builder: (context, wineList, child) {
        final priceCount = calculateSumOfPrices(wineList.allWines);
        return _statisticCard(
          value: '$priceCount',
          label: 'CHF of value',
          context: context,
        );
      },
    );
  }

  Widget labelStatistics(BuildContext context) {
    return Consumer<WineList>(
      builder: (context, wineList, child) {
        final labelCount = wineList.allWines.length;
        return _statisticCard(
          value: '$labelCount',
          label: 'labels tracked',
          context: context,
        );
      },
    );
  }

  Widget countryStatistics(BuildContext context) {
    return Consumer<WineList>(
      builder: (context, wineList, child) {
        final countries = wineList.allWines
            .map((wine) => wine.country.trim())
            .where((country) => country.isNotEmpty)
            .toSet();
        return _statisticCard(
          value: '${countries.length}',
          label: 'countries represented',
          onTap: onCountriesTap,
          context: context,
        );
      },
    );
  }

  Widget _statisticCard({
    required String value,
    required String label,
    VoidCallback? onTap,
    required BuildContext context,
  }) {
    final borderRadius = BorderRadius.circular(12);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  value,
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? _resolveDisplayName() {
    final user = AuthService.currentUser;
    final name = user?.displayName?.trim();
    if (name != null && name.isNotEmpty) {
      return name.split(' ').first;
    }

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return null;
  }

  int calculateSumOfPrices(List<Wine> wines) {
    int sum = 0;

    for (var wine in wines) {
      sum += (wine.price.toInt() * wine.bottleCount.toInt());
    }

    return sum;
  }

  int calculateSumOfWines(List<Wine> wines) {
    int sum = 0;

    for (var wine in wines) {
      sum += wine.bottleCount.toInt();
    }

    return sum;
  }
}
