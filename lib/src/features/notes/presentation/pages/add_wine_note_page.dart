import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:wiih/src/features/notes/domain/models/wine_note.dart';
import 'package:wiih/src/shared/widgets/gradient_background.dart';

class AddWineNotePage extends StatefulWidget {
  const AddWineNotePage({super.key});

  @override
  State<AddWineNotePage> createState() => _AddWineNotePageState();
}

class _AddWineNotePageState extends State<AddWineNotePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _rating = 90;

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return GradientBackground(
          child: Scaffold(
            appBar: AppBar(
              title: const Text('New tasting note'),
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
                    color: theme.colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: 'Wine name',
                            capitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                          ),
                          _buildTextField(
                            controller: _yearController,
                            label: 'Vintage year',
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: _validateYear,
                          ),
                          _buildTextField(
                            controller: _descriptionController,
                            label: 'Tasting notes',
                            keyboardType: TextInputType.multiline,
                            textInputAction: TextInputAction.newline,
                            minLines: 4,
                            maxLines: 6,
                          ),
                          const SizedBox(height: 16),
                          _buildRatingPicker(theme),
                          const SizedBox(height: 16),
                          _buildActions(),
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
    required TextEditingController controller,
    required String label,
    TextCapitalization capitalization = TextCapitalization.none,
    TextInputAction textInputAction = TextInputAction.done,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    int? minLines,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        controller: controller,
        textCapitalization: capitalization,
        textInputAction: textInputAction,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator ?? (value) => _validateRequired(value, label),
        minLines: minLines,
        maxLines: maxLines,
        decoration: _inputDecoration(label),
      ),
    );
  }

  Widget _buildRatingPicker(ThemeData theme) {
    final accent = theme.colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: NumberPicker(
                      value: _rating,
                      minValue: 50,
                      maxValue: 100,
                      axis: Axis.horizontal,
                      itemWidth: 44,
                      itemHeight: 44,
                      step: 1,
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      selectedTextStyle:
                          theme.textTheme.headlineSmall?.copyWith(
                        color: accent,
                        fontWeight: FontWeight.bold,
                      ),
                      onChanged: (value) => setState(() => _rating = value),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$_rating pts',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: accent,
                        ),
                      ),
                      Text(
                        'Scale 50 - 100',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          const Spacer(),
          FilledButton.icon(
            onPressed: _saveNote,
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Save note'),
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

  void _saveNote() {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) {
      return;
    }

    final year = int.parse(_yearController.text.trim());
    final note = WineNote(
      id: DateTime.now().millisecondsSinceEpoch,
      name: _nameController.text.trim(),
      year: year,
      description: _descriptionController.text.trim(),
      rating: _rating,
    );

    FocusScope.of(context).unfocus();
    Navigator.pop(context, note);
  }

  String? _validateRequired(String? value, String fieldLabel) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter ${fieldLabel.toLowerCase()}.';
    }
    return null;
  }

  String? _validateYear(String? value) {
    final trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) {
      return 'Please enter a vintage year.';
    }
    final parsed = int.tryParse(trimmed);
    final currentYear = DateTime.now().year;
    if (parsed == null || parsed < 1900 || parsed > currentYear) {
      return 'Enter a year between 1900 and $currentYear.';
    }
    return null;
  }
}
