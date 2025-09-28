// Updated EditWinePage with AnimatedWineBottleIcon and persistent image preview

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/src/shared/widgets/animated_wine_bottle.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/country_selection_dialog.dart';
import 'package:wiih/src/shared/widgets/gradient_background.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/grape_variety_selection_dialog.dart';
import 'package:wiih/src/shared/services/image_helper.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/type_selection_dialog.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/countries/domain/models/wine_countries.dart';
import 'package:wiih/src/features/cellar/domain/models/wine_options.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/year_picker.dart';

class EditWinePage extends StatefulWidget {
  final Wine wine;

  const EditWinePage({super.key, required this.wine});

  @override
  State<EditWinePage> createState() => _EditWinePageState();
}

class _EditWinePageState extends State<EditWinePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wineryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedCountry = WineCountries.countries[0];
  String selectedType = WineOptions.types[0];
  List<String> selectedGrapeVarieties = [];
  File? _image;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    nameController.text = widget.wine.name;
    wineryController.text = widget.wine.winery;
    priceController.text = widget.wine.price.toString();
    yearController.text = widget.wine.year.toString();
    selectedType = widget.wine.type;
    selectedCountry = widget.wine.country;
    selectedGrapeVarieties =
        widget.wine.grapeVariety.split(',').map((e) => e.trim()).toList();
  }

  @override
  void dispose() {
    nameController.dispose();
    wineryController.dispose();
    priceController.dispose();
    yearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context, constraints) => GradientBackground(
                child: Scaffold(
              appBar: AppBar(title: const Text('Edit your collection')),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: SingleChildScrollView(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(8.0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              'Name', nameController, TextCapitalization.words),
                          _buildTextField('Winery', wineryController,
                              TextCapitalization.words),
                          _buildCountrySelector(),
                          _buildTypeSelection(),
                          _buildGrapeVarietiesSelector(),
                          _buildNumberField('Year', yearController),
                          _buildNumberField('Price', priceController),
                          _buildImageButtons(),
                          _buildActionButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )));
  }

  Padding _buildTextField(String label, TextEditingController controller,
      TextCapitalization capitalization) {
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

  Padding _buildNumberField(String label, TextEditingController controller) {
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

  Padding _buildCountrySelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await showDialog(
            context: context,
            builder: (context) =>
                CountrySelectionDialog(selectedCountry: selectedCountry),
          );
          if (result != null) setState(() => selectedCountry = result);
        },
        child: _buildInputDecorator('Country', selectedCountry),
      ),
    );
  }

  Padding _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          String? result = await showDialog(
            context: context,
            builder: (context) =>
                TypeSelectionDialog(selectedType: selectedType),
          );
          if (result != null) setState(() => selectedType = result);
        },
        child: _buildInputDecorator('Type', selectedType),
      ),
    );
  }

  Padding _buildGrapeVarietiesSelector() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () async {
          final grapeVarieties = [
            ...?WineOptions.grapeVarietiesByType[selectedType]
          ]..sort();
          List<String>? result = await showDialog(
            context: context,
            builder: (context) => GrapeVarietySelectionDialog(
              grapeVarieties: grapeVarieties,
              selectedValues: Set.from(selectedGrapeVarieties),
            ),
          );
          if (result != null) setState(() => selectedGrapeVarieties = result);
        },
        child: _buildInputDecorator(
          'Grape Varieties',
          selectedGrapeVarieties.isNotEmpty
              ? selectedGrapeVarieties.join(', ')
              : 'Select',
        ),
      ),
    );
  }

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

  Padding _buildImageButtons() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton.icon(
              onPressed: _captureImage, label: const Icon(Icons.camera_alt)),
          const SizedBox(width: 8),
          ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text('Pick Image')),
          const SizedBox(width: 16),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child:
                  Image.file(_image!, width: 60, height: 80, fit: BoxFit.cover),
            )
          else if (widget.wine.imageUrl != null &&
              widget.wine.imageUrl!.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(widget.wine.imageUrl!,
                  width: 60, height: 80, fit: BoxFit.cover),
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
            onPressed: _saveEditedWine,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: _deleteWine,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    File? pickedImage = await pickImage();
    if (pickedImage != null) setState(() => _image = pickedImage);
  }

  Future<void> _captureImage() async {
    File? capturedImage = await captureImage();
    if (capturedImage != null) setState(() => _image = capturedImage);
  }

  Future<String?> _uploadImage() async {
    if (_image != null) return await uploadImage(_image!);
    return null;
  }

  Future<void> _saveEditedWine() async {
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

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    String? imageUrl;
    try {
      imageUrl = await _uploadImage();
    } catch (_) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    if (!mounted) return;

    final updatedWine = Wine(
      id: widget.wine.id,
      name: nameController.text.trim(),
      type: selectedType,
      winery: wineryController.text.trim(),
      country: selectedCountry,
      grapeVariety: selectedGrapeVarieties.join(', '),
      year: int.tryParse(yearController.text) ?? 0,
      price: int.tryParse(priceController.text) ?? 0,
      bottleCount: widget.wine.bottleCount,
      imageUrl: imageUrl ?? widget.wine.imageUrl,
    );

    navigator.pop(); // Close saving dialog
    navigator.pop(updatedWine); // Return wine to previous page
  }

  Future<void> _deleteWine() async {
    final navigator = Navigator.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Wine'),
        content: const Text('Are you sure you want to delete this wine?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && navigator.mounted) navigator.pop(true);
    });
  }

  bool _isSaveButtonEnabled() {
    return nameController.text.isNotEmpty &&
        wineryController.text.isNotEmpty &&
        selectedCountry.isNotEmpty &&
        selectedGrapeVarieties.isNotEmpty &&
        yearController.text.isNotEmpty &&
        priceController.text.isNotEmpty;
  }
}
