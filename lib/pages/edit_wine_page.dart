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
  final TextEditingController wineryController;
  final TextEditingController priceController;
  final TextEditingController yearController;

  String selectedCountry = WineOptions.countries[0];
  String selectedType = WineOptions.types[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  _EditWinePageState()
      : nameController = TextEditingController(),
        wineryController = TextEditingController(),
        priceController = TextEditingController(),
        yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

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
              _buildTextField('Name', nameController, TextCapitalization.words),
              _buildTypeSelection(),
              _buildTextField('Winery', wineryController, TextCapitalization.words),
              _buildCountrySelector(),
              _buildGrapeVarietiesSelector(),
              _buildTextField('Year', yearController, TextCapitalization.none, TextInputType.number),
              _buildTextField('Price', priceController, TextCapitalization.none, TextInputType.number),
              _buildImageButtons(),
              _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  // Method to initialize fields with wine data
  void _initializeFields() {
    nameController.text = widget.wine.name;
    yearController.text = widget.wine.year.toString();
    selectedType = widget.wine.type;
    wineryController.text = widget.wine.winery;
    selectedCountry = widget.wine.country;
    priceController.text = widget.wine.price.toString();
    selectedGrapeVarieties = widget.wine.grapeVariety.split(',').map((e) => e.trim()).toList();
  }

  // Builds the text field for user input
  Padding _buildTextField(String label, TextEditingController controller, TextCapitalization capitalization, [TextInputType keyboardType = TextInputType.text]) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textCapitalization: capitalization,
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: keyboardType == TextInputType.number ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly] : [],
        decoration: InputDecoration(
          labelText: label,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  // Builds the type selection widget
  Padding _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await _showSelectionDialog(context, TypeSelectionDialog(selectedType: selectedType));
          if (result != null) {
            setState(() {
              selectedType = result;
            });
          }
        },
        child: _buildInputDecorator('Type', selectedType),
      ),
    );
  }

  // Builds the input decorator for various selections
  InputDecorator _buildInputDecorator(String label, String value) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: Theme.of(context).colorScheme.onSecondaryContainer,
          ),
        ),
      ),
      child: Text(value),
    );
  }

  // Builds the country selector widget
  Padding _buildCountrySelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return CountrySelectionDialog(selectedCountry: selectedCountry);
            },
          );
          if (result != null) {
            setState(() {
              selectedCountry = result;
            });
          }
        },
        child: _buildInputDecorator('Country', selectedCountry),
      ),
    );
  }

  // Builds the grape varieties selector widget
  Padding _buildGrapeVarietiesSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          List<String>? result = await showDialog(
            context: context,
            builder: (BuildContext context) {
              return GrapeVarietySelectionDialog(
                grapeVarieties: WineOptions.grapeVarieties..sort(),
                selectedValues: Set.from(selectedGrapeVarieties),
              );
            },
          );
          if (result != null) {
            setState(() {
              selectedGrapeVarieties = result..sort();
            });
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Grape Varieties',
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
          child: Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: selectedGrapeVarieties.map(
              (grape) => Chip(
                deleteIconColor: Theme.of(context).colorScheme.primary,
                label: Text(grape, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                onDeleted: () {
                  setState(() {
                    selectedGrapeVarieties.remove(grape);
                  });
                },
              ),
            ).toList(),
          ),
        ),
      ),
    );
  }

  // Builds the image selection buttons
  Padding _buildImageButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _captureImage,
            label: const Icon(Icons.camera_alt),
          ),
          const SizedBox(width: 4),
          ElevatedButton.icon(
            onPressed: _pickImage,
            label: const Text('Pick Image'),
            icon: const Icon(Icons.image),
          ),
          const SizedBox(width: 16),
          _image != null ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary) : Container(),
        ],
      ),
    );
  }

  // Builds the action buttons (Save and Delete)
  Row _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _saveEditedWine(context),
          child: const Text('Save'),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: () => _deleteWine(context),
          child: const Text('Delete'),
        ),
      ],
    );
  }

  // Shows a selection dialog
  Future<T?> _showSelectionDialog<T>(BuildContext context, Widget dialog) async {
    return await showDialog<T>(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
    );
  }

  // Picks an image from the gallery
  Future<void> _pickImage() async {
    File? pickedImage = await pickImage();
    setState(() {
      _image = pickedImage;
    });
  }

  // Captures an image using the camera
  Future<void> _captureImage() async {
    File? capturedImage = await captureImage();
    setState(() {
      _image = capturedImage;
    });
  }

  // Uploads the selected image
  Future<String?> _uploadImage() async {
    if (_image != null) {
      return await uploadImage(_image!);
    }
    return null;
  }

  // Saves the edited wine details
  Future<void> _saveEditedWine(BuildContext context) async {
    if (_isSaveButtonEnabled()) {
      String name = nameController.text.trim();
      String type = selectedType;
      String winery = wineryController.text.trim();
      String country = selectedCountry;
      String grapeVariety = selectedGrapeVarieties.join(', ');
      int year = int.tryParse(yearController.text) ?? 0;
      int price = int.tryParse(priceController.text) ?? 0;
      int bottleCount = widget.wine.bottleCount;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      String? imageUrl = await _uploadImage();
      Wine updatedWine = Wine(
        id: widget.wine.id,
        name: name,
        type: type,
        winery: winery,
        country: country,
        grapeVariety: grapeVariety,
        year: year,
        price: price,
        bottleCount: bottleCount,
        imageUrl: imageUrl ?? widget.wine.imageUrl,
      );

      Navigator.pop(context);
      Navigator.pop(context, updatedWine);
    }
  }

  // Deletes the wine entry
  Future<void> _deleteWine(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Wine'),
          content: const Text('Are you sure you want to delete this wine?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the alert dialog
                Navigator.pop(context, null); // Return null to indicate deletion
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  // Checks if the Save button should be enabled
  bool _isSaveButtonEnabled() {
    return nameController.text.isNotEmpty &&
        wineryController.text.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        selectedGrapeVarieties.isNotEmpty &&
        yearController.text.isNotEmpty &&
        priceController.text.isNotEmpty;
  }
}
