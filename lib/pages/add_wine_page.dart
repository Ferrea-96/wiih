import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/classes/animated_wine_bottle.dart';
import 'package:wiih/classes/country_selection.dart';
import 'package:wiih/classes/image_helper.dart';
import 'package:wiih/classes/type_selection.dart';
import 'package:wiih/classes/wine/wine.dart';
import 'package:wiih/classes/grapevariety_selection.dart';
import 'package:wiih/classes/wine/wine_countries.dart';
import 'package:wiih/classes/wine/wine_options.dart';
import 'package:wiih/classes/year_selection.dart';

class AddWinePage extends StatefulWidget {
  const AddWinePage({super.key});

  @override
  _AddWinePageState createState() => _AddWinePageState();
}

class _AddWinePageState extends State<AddWinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wineryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedType = WineOptions.types[0];
  String selectedCountry = WineCountries.countries[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enrich your collection'),
      ),
      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Card(
            elevation: 4,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Name', nameController, TextCapitalization.words),
                  _buildTextField('Winery', wineryController, TextCapitalization.words),
                  _buildCountrySelection(),
                  const SizedBox(height: 16),
                  _buildTypeSelection(),
                  _buildGrapeVarietySelection(),
                  _buildNumberInputField('Year', yearController),
                  _buildNumberInputField('Price', priceController),
                  const SizedBox(height: 16),
                  _buildImageSelection(),
                  const SizedBox(height: 16),
                  _buildActionButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, TextCapitalization capitalization) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        textCapitalization: capitalization,
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountrySelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await _showSelectionDialog(
            context,
            CountrySelectionDialog(selectedCountry: selectedCountry),
          );
          if (result != null) setState(() => selectedCountry = result);
        },
        child: _buildInputDecorator('Country', selectedCountry),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await _showSelectionDialog(
            context,
            TypeSelectionDialog(selectedType: selectedType),
          );
          if (result != null) setState(() => selectedType = result);
        },
        child: _buildInputDecorator('Type', selectedType),
      ),
    );
  }

  Widget _buildGrapeVarietySelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final grapeVarieties = [...?WineOptions.grapeVarietiesByType[selectedType]]..sort();
          List<String>? result = await _showSelectionDialog(
            context,
            GrapeVarietySelectionDialog(
              grapeVarieties: grapeVarieties,
              selectedValues: Set.from(selectedGrapeVarieties),
            ),
          );
          if (result != null) {
            setState(() => selectedGrapeVarieties = result..sort());
          }
        },
        child: _buildInputDecorator(
          'Grape Varieties',
          selectedGrapeVarieties.isNotEmpty ? selectedGrapeVarieties.join(', ') : 'Select',
        ),
      ),
    );
  }
  Padding _buildNumberInputField(String label, TextEditingController controller) {
    if (label == 'Year') {
      int currentYear = DateTime.now().year;
      int initialYear = int.tryParse(controller.text) ?? currentYear;
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () async {
            int? result = await showYearPickerDialog(context, initialYear);
            if (result != null) {
              setState(() => controller.text = result.toString());
            }
          },
          child: _buildInputDecorator(
              'Year', controller.text.isEmpty ? 'Select' : controller.text),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderSide: BorderSide(
                width: 1,
                color: Theme.of(context).colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton.icon(onPressed: _captureImage, label: const Icon(Icons.camera_alt)),
          const SizedBox(width: 8),
          ElevatedButton.icon(onPressed: _pickImage, icon: const Icon(Icons.image), label: const Text('Pick Image')),
          const SizedBox(width: 16),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(_image!, width: 60, height: 80, fit: BoxFit.cover),
            ),
        ],
      ),
    );
  }

  Padding _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton(
            onPressed: _saveWine,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputDecorator(String label, String value) {
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

  Future<T?> _showSelectionDialog<T>(BuildContext context, Widget dialog) async {
    return await showDialog<T>(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  Future<void> _pickImage() async {
    File? pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() => _image = pickedImage);
    }
  }

  Future<void> _captureImage() async {
    File? capturedImage = await captureImage();
    if (capturedImage != null) {
      setState(() => _image = capturedImage);
    }
  }

  Future<void> _saveWine() async {
    if (!_isSaveButtonEnabled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedWineBottleIcon(),
              const SizedBox(height: 16),
              const Text('Saving wine...'),
            ],
          ),
        );
      },
    );

    String? imageUrl;
    try {
      imageUrl = _image != null ? await uploadImage(_image!) : null;
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    Wine newWine = Wine(
      id: DateTime.now().millisecondsSinceEpoch,
      name: nameController.text,
      type: selectedType,
      winery: wineryController.text,
      country: selectedCountry,
      grapeVariety: selectedGrapeVarieties.join(', '),
      year: int.tryParse(yearController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
      imageUrl: imageUrl,
      bottleCount: 1,
    );

    Navigator.pop(context);
    Navigator.pop(context, newWine);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Wine saved successfully')),
    );
  }

  bool _isSaveButtonEnabled() {
    return nameController.text.isNotEmpty &&
        selectedType.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        yearController.text.isNotEmpty &&
        wineryController.text.isNotEmpty;
  }
}
