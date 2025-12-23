import 'package:flutter/material.dart';
import 'package:wiih/src/features/countries/domain/models/wine_countries.dart';

class CountrySelectionDialog extends StatefulWidget {
  final String selectedCountry;

  const CountrySelectionDialog({super.key, required this.selectedCountry});

  @override
  State<CountrySelectionDialog> createState() => _CountrySelectionDialogState();
}

class _CountrySelectionDialogState extends State<CountrySelectionDialog> {
  late String _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = widget.selectedCountry;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Country'),
      content: SizedBox(
        height: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: WineCountries.countries
                .map(
                  (country) => RadioListTile<String>(
                    title: Text(country),
                    value: country,
                    groupValue: _selectedCountry,
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _selectedCountry = value);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, _selectedCountry),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
