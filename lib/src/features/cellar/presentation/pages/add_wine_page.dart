import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/cellar/domain/models/wine_options.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/country_selection_dialog.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/grape_variety_selection_dialog.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/type_selection_dialog.dart';
import 'package:wiih/src/features/cellar/presentation/widgets/year_picker.dart';
import 'package:wiih/src/features/countries/domain/models/wine_countries.dart';
import 'package:wiih/src/shared/services/image_helper.dart';
import 'package:wiih/src/shared/widgets/animated_wine_bottle.dart';
import 'package:wiih/src/shared/widgets/gradient_background.dart';

class AddWinePage extends StatefulWidget {
  const AddWinePage({super.key});

  @override
  State<AddWinePage> createState() => _AddWinePageState();
}

class _AddWinePageState extends State<AddWinePage> {
  final _formKey = GlobalKey<FormState>();
  final _grapeFieldKey = GlobalKey<FormFieldState<List<String>>>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController wineryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController yearController = TextEditingController();

  String selectedType = WineOptions.types.first;
  String selectedCountry = WineCountries.countries.first;
  List<String> selectedGrapeVarieties = [];
  File? _image;

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
      builder: (context, constraints) {
        return GradientBackground(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Enrich your collection'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'Name',
                            controller: nameController,
                            capitalization: TextCapitalization.words,
                          ),
                          _buildTextField(
                            label: 'Winery',
                            controller: wineryController,
                            capitalization: TextCapitalization.words,
                          ),
                          _buildCountrySelection(),
                          const SizedBox(height: 16),
                          _buildTypeSelection(),
                          _buildGrapeVarietySelection(),
                          _buildYearSelection(),
                          _buildPriceField(),
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
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextCapitalization capitalization = TextCapitalization.none,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        textCapitalization: capitalization,
        textInputAction: TextInputAction.next,
        decoration: _inputDecoration(label),
        validator: (value) => _validateRequired(value, label),
      ),
    );
  }

  Widget _buildCountrySelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FormField<String>(
        validator: (_) => _validateSelection(selectedCountry, 'Country'),
        builder: (state) {
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final result = await _showSelectionDialog<String>(
                context,
                CountrySelectionDialog(selectedCountry: selectedCountry),
              );
              if (result != null) {
                setState(() => selectedCountry = result);
                state.didChange(result);
              }
            },
            child: _buildInputDecorator(
              label: 'Country',
              value: selectedCountry,
              errorText: state.errorText,
            ),
          );
        },
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FormField<String>(
        validator: (_) => _validateSelection(selectedType, 'Type'),
        builder: (state) {
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final result = await _showSelectionDialog<String>(
                context,
                TypeSelectionDialog(selectedType: selectedType),
              );
              if (result != null) {
                setState(() {
                  selectedType = result;
                  final allowed =
                      WineOptions.grapeVarietiesByType[selectedType] ?? [];
                  selectedGrapeVarieties = selectedGrapeVarieties
                      .where((grape) => allowed.contains(grape))
                      .toList();
                });
                state.didChange(result);
                _grapeFieldKey.currentState?.validate();
              }
            },
            child: _buildInputDecorator(
              label: 'Type',
              value: selectedType,
              errorText: state.errorText,
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrapeVarietySelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FormField<List<String>>(
        key: _grapeFieldKey,
        validator: (_) => selectedGrapeVarieties.isEmpty
            ? 'Select at least one grape variety'
            : null,
        builder: (state) {
          final grapeVarieties = <String>{
            ...?WineOptions.grapeVarietiesByType[selectedType],
          }.toList()
            ..sort();
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final result = await _showSelectionDialog<List<String>>(
                context,
                GrapeVarietySelectionDialog(
                  grapeVarieties: grapeVarieties,
                  selectedValues: Set.from(selectedGrapeVarieties),
                ),
              );
              if (result != null) {
                setState(() => selectedGrapeVarieties = result..sort());
                state.didChange(selectedGrapeVarieties);
              }
            },
            child: _buildInputDecorator(
              label: 'Grape Varieties',
              value: selectedGrapeVarieties.join(', '),
              placeholder: 'Select at least one variety',
              errorText: state.errorText,
            ),
          );
        },
      ),
    );
  }

  Widget _buildYearSelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: FormField<String>(
        validator: (_) => _validateYear(yearController.text),
        builder: (state) {
          return GestureDetector(
            onTap: () async {
              FocusScope.of(context).unfocus();
              final currentYear = DateTime.now().year;
              final initialYear =
                  int.tryParse(yearController.text) ?? currentYear;
              final result = await showYearPickerDialog(context, initialYear);
              if (result != null) {
                setState(() => yearController.text = result.toString());
                state.didChange(yearController.text);
              }
            },
            child: _buildInputDecorator(
              label: 'Year',
              value: yearController.text,
              errorText: state.errorText,
            ),
          );
        },
      ),
    );
  }

  Widget _buildPriceField() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: priceController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        decoration: _inputDecoration('Price (CHF)'),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(6),
        ],
        validator: _validatePrice,
      ),
    );
  }

  Widget _buildImageSelection() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: _captureImage,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Capture'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.image),
            label: const Text('Pick Image'),
          ),
          const SizedBox(width: 16),
          if (_image != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _image!,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(8),
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

  InputDecoration _inputDecoration(String label) {
    final color = Theme.of(context).colorScheme.onSecondaryContainer;
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: color),
      ),
    );
  }

  Widget _buildInputDecorator({
    required String label,
    required String value,
    String placeholder = 'Select',
    String? errorText,
  }) {
    final displayValue = value.isEmpty ? placeholder : value;
    final isPlaceholder = value.isEmpty;
    final theme = Theme.of(context);
    return InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        border: OutlineInputBorder(
          borderSide: BorderSide(
            width: 1,
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
      child: Text(
        displayValue,
        style: isPlaceholder
            ? theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              )
            : null,
      ),
    );
  }

  Future<T?> _showSelectionDialog<T>(BuildContext context, Widget dialog) {
    return showDialog<T>(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  Future<void> _pickImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() => _image = pickedImage);
    }
  }

  Future<void> _captureImage() async {
    final capturedImage = await captureImage();
    if (capturedImage != null) {
      setState(() => _image = capturedImage);
    }
  }

  Future<void> _saveWine() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedWineBottleIcon(),
              SizedBox(height: 16),
              Text('Saving wine...'),
            ],
          ),
        );
      },
    );

    String? imageUrl;
    try {
      imageUrl = _image != null ? await uploadImage(_image!) : null;
    } catch (_) {
      if (!mounted) return;
      navigator.pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Image upload failed')),
      );
      return;
    }

    if (!mounted) return;

    final newWine = Wine(
      id: DateTime.now().millisecondsSinceEpoch,
      name: nameController.text.trim(),
      type: selectedType,
      winery: wineryController.text.trim(),
      country: selectedCountry,
      grapeVariety: selectedGrapeVarieties.join(', '),
      year: int.parse(yearController.text),
      price: int.parse(priceController.text),
      imageUrl: imageUrl,
      bottleCount: 1,
    );

    navigator.pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Wine saved successfully')),
    );
    navigator.pop(newWine);
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateSelection(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Select a $fieldName';
    }
    return null;
  }

  String? _validateYear(String value) {
    if (value.trim().isEmpty) {
      return 'Year is required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid year';
    }
    final currentYear = DateTime.now().year + 1;
    if (parsed < 1900 || parsed > currentYear) {
      return 'Year must be between 1900 and $currentYear';
    }
    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final parsed = int.tryParse(value);
    if (parsed == null) {
      return 'Enter a valid number';
    }
    if (parsed < 0) {
      return 'Price cannot be negative';
    }
    return null;
  }
}
