// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/classes/country_selection.dart';
import 'package:wiih/classes/image_helper.dart';
import 'package:wiih/classes/type_selection.dart';
import 'package:wiih/classes/wine.dart';
import 'package:wiih/classes/grapevariety_selection.dart';

class AddWinePage extends StatefulWidget {
  const AddWinePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AddWinePageState createState() => _AddWinePageState();
}

class _AddWinePageState extends State<AddWinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController wineryController = TextEditingController();
  final TextEditingController countryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedType = WineOptions.types[0];
  String selectedCountry = WineOptions.countries[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: nameController,
                  decoration: InputDecoration(
                      labelText: 'Name',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    String? result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return TypeSelectionDialog(selectedType: selectedType);
                      },
                    );

                    if (result != null) {
                      setState(() {
                        selectedType = result;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Type',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                    child: Text(selectedType),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  textCapitalization: TextCapitalization.words,
                  controller: wineryController,
                  decoration: InputDecoration(
                      labelText: 'Winery',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    String? result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CountrySelectionDialog(
                            selectedCountry: selectedCountry);
                      },
                    );

                    if (result != null) {
                      setState(() {
                        selectedCountry = result;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Country',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                    child: Text(selectedCountry),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: GestureDetector(
                  onTap: () async {
                    List<String>? result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return GrapeVarietySelectionDialog(
                          grapeVarieties: WineOptions.grapeVarieties,
                          selectedValues: Set.from(selectedGrapeVarieties),
                        );
                      },
                    );

                    if (result != null) {
                      setState(() {
                        selectedGrapeVarieties = result;
                      });
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Grape Varieties',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 1,
                          color: Theme.of(context)
                              .colorScheme
                              .onSecondaryContainer,
                        ),
                      ),
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 4.0,
                      children: selectedGrapeVarieties
                          .map(
                            (grape) => Chip(
                              deleteIconColor:
                                  Theme.of(context).colorScheme.primary,
                              label: Text(grape,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary)),
                              onDeleted: () {
                                setState(() {
                                  selectedGrapeVarieties.remove(grape);
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: yearController,
                  keyboardType:
                      TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Allow only numeric input
                  decoration: InputDecoration(
                      labelText: 'Year',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly
                  ], // Allow only numeric input
                  decoration: InputDecoration(
                      labelText: 'Price',
                      enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              width: 1,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSecondaryContainer))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _pickImage();
                      },
                      label: const Text('Pick Image'),
                      icon: const Icon(Icons.image),
                    ),
                    const SizedBox(width: 16),
                    _image != null
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : Container(),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _saveWine(context);
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _cancelAddWine(context);
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    File? pickedImage = await pickImage();
    setState(() {
      _image = pickedImage;
    });
  }

  Future<String?> _uploadImage() async {
    if (_image != null) {
      return await uploadImage(_image!);
    }
    return null;
  }

  Future<void> _saveWine(BuildContext context) async {
    if (_isSaveButtonEnabled()) {
      // Extracting data from input fields...
      String name = nameController.text;
      String type = selectedType;
      String winery = wineryController.text;
      String country = selectedCountry;
      String grapeVariety = selectedGrapeVarieties.join(', ');
      int year = int.tryParse(yearController.text) ?? 0;
      int price = int.tryParse(priceController.text) ?? 0;

      // Show circular progress indicator while saving
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Saving wine..."),
              ],
            ),
          );
        },
      );

      String? imageUrl;

      // Perform the save operation
      if (_image != null) {
        imageUrl = await _uploadImage();
      }

      // Check if required fields are filled
      if (name.isNotEmpty &&
          type.isNotEmpty &&
          winery.isNotEmpty &&
          country.isNotEmpty) {
        Navigator.pop(context); // Dismiss the progress dialog

        Navigator.pop(
          context,
          Wine(
            id: DateTime.now().millisecondsSinceEpoch,
            name: name,
            type: type,
            year: year,
            winery: winery,
            country: country,
            grapeVariety: grapeVariety,
            price: price,
            imageUrl: imageUrl,
            bottleCount: 1,
          ),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wine saved successfully')),
        );
      } else {
        // Show an error message if any required field is empty
        Navigator.pop(context); // Dismiss the progress dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Invalid input. Please check and try again.')),
        );
      }
    } else {
      // Show error snackbar if not all required fields are filled
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  void _cancelAddWine(BuildContext context) {
    Navigator.pop(context);
  }

  bool _isSaveButtonEnabled() {
    return nameController.text.isNotEmpty &&
        selectedType.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        yearController.text.isNotEmpty &&
        wineryController.text.isNotEmpty;
  }
}
