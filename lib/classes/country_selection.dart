import 'package:flutter/material.dart';
import 'package:wiih/classes/wine.dart';

class CountrySelectionDialog extends StatefulWidget {
  final String selectedCountry;

  CountrySelectionDialog({required this.selectedCountry});

  @override
  _CountrySelectionDialogState createState() =>
      _CountrySelectionDialogState(selectedCountry: selectedCountry);
}

class _CountrySelectionDialogState extends State<CountrySelectionDialog> {
  String selectedCountry;

  _CountrySelectionDialogState({required this.selectedCountry});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: AlertDialog(
        title: const Text('Select Country'),
        content: Column(
          children: WineOptions.countries
              .map(
                (country) => RadioListTile(
                  title: Text(country),
                  value: country,
                  groupValue: selectedCountry,
                  onChanged: (String? value) {
                    setState(() {
                      selectedCountry = value!;
                    });
                  },
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, selectedCountry);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
