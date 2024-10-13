// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/classes/country_selection.dart';
import 'package:wiih/classes/grapevariety_selection.dart';
import 'package:wiih/classes/image_helper.dart';
import 'package:wiih/classes/type_selection.dart';
import 'package:wiih/classes/wine.dart';

class EditWinePage extends StatefulWidget {
  final Wine wine;

  const EditWinePage({super.key, required this.wine});

  @override
  _EditWinePageState createState() => _EditWinePageState();
}

class _EditWinePageState extends State<EditWinePage> {
  final TextEditingController nameController;
  final TextEditingController typeController;
  final TextEditingController wineryController;
  final TextEditingController countryController;
  final TextEditingController priceController;
  final TextEditingController yearController;

  String selectedCountry = WineOptions.countries[0];
  String selectedType = WineOptions.types[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  _EditWinePageState()
      : nameController = TextEditingController(),
        typeController = TextEditingController(),
        wineryController = TextEditingController(),
        countryController = TextEditingController(),
        priceController = TextEditingController(),
        yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.wine.name;
    yearController.text = widget.wine.year.toString();
    selectedType = widget.wine.type;
    wineryController.text = widget.wine.winery;
    selectedCountry = widget.wine.country;
    priceController.text = widget.wine.price.toString();
    // Set initial values for selectedGrapeVarieties
    selectedGrapeVarieties =
        widget.wine.grapeVariety.split(',').map((e) => e.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                  keyboardType: TextInputType.number,
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
                      _saveEditedWine(context);
                    },
                    child: const Text('Save'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      _deleteWine(context);
                    },
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ]),
          ),
        ));
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

  Future<void> _saveEditedWine(BuildContext context) async {
    if (_isSaveButtonEnabled()) {
      String name = nameController.text;
      String type = selectedType;
      String winery = wineryController.text;
      String country = selectedCountry;
      String grapeVariety = selectedGrapeVarieties.join(', ');
      int year = int.tryParse(yearController.text) ?? 0;
      int price = int.tryParse(priceController.text) ?? 0;
      int bottleCount = widget.wine.bottleCount;

      // Show circular progress indicator while saving
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent users from dismissing the dialog
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

      try {
        // Perform the save operation
        if (_image != null) {
          imageUrl = await _uploadImage();
        } else {
          // If no new image is selected, preserve the existing image URL
          imageUrl = widget.wine.imageUrl;
        }

        if (name.isNotEmpty &&
            type.isNotEmpty &&
            winery.isNotEmpty &&
            country.isNotEmpty) {
          // Close the progress dialog
          Navigator.pop(context);

          // Update the wine in the wineList with the preserved or new image URL
          Wine updatedWine = Wine(
            id: widget.wine.id,
            name: name,
            type: type,
            year: year,
            winery: winery,
            country: country,
            grapeVariety: grapeVariety,
            price: price,
            imageUrl: imageUrl,
            bottleCount: bottleCount,
          );

          // Notify the parent widget about the update
          Navigator.pop(context, updatedWine);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Wine saved successfully')),
          );
        } else {
          // Close the progress dialog
          Navigator.pop(context);

          // Show an error message or handle invalid input
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid input. Please check and try again.'),
            ),
          );
        }
      } catch (e) {
        // Close the progress dialog
        Navigator.pop(context);

        // Handle errors related to saving the wine
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error saving wine. Please try again later.'),
          ),
        );
      }
    } else {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
    }
  }

  void _deleteWine(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wine'),
        content: const Text('Are you sure you want to delete this wine?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Delete the image from Firebase Storage
              if (widget.wine.imageUrl != null) {
                await deleteImage(widget.wine.imageUrl!);
              }

              Navigator.pop(context); // Close the dialog
              Navigator.pop(context, true); // Pass true to indicate deletion
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  bool _isSaveButtonEnabled() {
    // Check if all required fields are filled
    return nameController.text.isNotEmpty &&
        selectedType.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        yearController.text.isNotEmpty &&
        wineryController.text.isNotEmpty;
  }
}
