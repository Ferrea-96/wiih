import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wiih/src/features/notes/data/note_repository.dart';
import 'package:wiih/src/features/notes/domain/models/wine_note.dart';
import 'package:wiih/src/features/notes/presentation/pages/add_wine_note_page.dart';
import 'package:wiih/src/features/notes/presentation/pages/edit_wine_note_page.dart';
import 'package:wiih/src/features/notes/presentation/state/notes_list.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final NotesList _notesList;
  final TextEditingController _searchController = TextEditingController();

  String selectedSortOption = _sortOptions.first.value;
  String selectedRatingFilter = _ratingFilters.first.value;
  String _searchTerm = '';

  @override
  void initState() {
    super.initState();
    _notesList = Provider.of<NotesList>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await NoteRepository.loadNotes(_notesList);
      if (!mounted) return;
      unawaited(_sortWineNotes(selectedSortOption, persist: false));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Consumer<NotesList>(
      builder: (context, list, child) {
        final notes = _applyFilters(list.wineNotes);
        return CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _NotesToolbarDelegate(
                height: 272,
                child: _buildToolbar(theme),
              ),
            ),
            if (notes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _buildEmptyState(theme),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final note = notes[index];
                      return Padding(
                        padding: EdgeInsets.only(
                          bottom: index == notes.length - 1 ? 0 : 12,
                        ),
                        child: _buildWineNoteCard(context, note),
                      );
                    },
                    childCount: notes.length,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildToolbar(ThemeData theme) {
    final surface = theme.colorScheme.surface.withOpacity(0.95);
    final shadowColor = theme.colorScheme.primary.withOpacity(0.08);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchTerm.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.close),
                                  onPressed: () {
                                    _searchController.clear();
                                    _onSearchChanged('');
                                  },
                                ),
                          labelText: 'Search your notes',
                          hintText: 'Wine, vintage, keywords...',
                          filled: true,
                          fillColor:
                              theme.colorScheme.surface.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide(
                              color: theme.colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    FilledButton.icon(
                      onPressed: () => _navigateToAddNotePage(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add note'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildRatingFilterChips(theme),
                const SizedBox(height: 16),
                _buildSortChips(theme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRatingFilterChips(ThemeData theme) {
    final defaultLabelColor = theme.textTheme.bodyMedium?.color;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: _ratingFilters.map((filter) {
          final isSelected = selectedRatingFilter == filter.value;
          final color = _colorForFilter(theme, filter.value);
          final onColor = _onColor(color);
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(
                filter.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected ? onColor : defaultLabelColor,
                  fontWeight: isSelected ? FontWeight.w600 : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) => _updateFilter(filter.value),
              showCheckmark: isSelected,
              checkmarkColor: onColor,
              backgroundColor: _tintFor(color, theme, 0.12),
              selectedColor: _tintFor(color, theme, 0.28),
              side: BorderSide(
                color: isSelected
                    ? color
                    : theme.colorScheme.outlineVariant,
              ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildSortChips(ThemeData theme) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: _sortOptions.map((option) {
          final isSelected = selectedSortOption == option.value;
          final color = theme.colorScheme.primary;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(option.label),
              selected: isSelected,
              onSelected: (_) => _onSortChanged(option.value),
              selectedColor: color.withOpacity(0.18),
              backgroundColor: theme.colorScheme.surface.withOpacity(0.7),
              labelStyle: theme.textTheme.bodyMedium?.copyWith(
                color:
                    isSelected ? color : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : null,
              ),
              side: BorderSide(
                color: isSelected
                    ? color
                    : theme.colorScheme.outlineVariant,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(growable: false),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 48,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No notes yet.',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Capture tasting impressions, standout vintages, and personal highlights to build your wine journal.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _navigateToAddNotePage(context),
              icon: const Icon(Icons.add),
              label: const Text('Add your first note'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWineNoteCard(BuildContext context, WineNote wineNote) {
    final theme = Theme.of(context);
    final ratingColor = _colorForRating(theme, wineNote.rating);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: ratingColor.withOpacity(0.28)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _navigateToEditNotePage(context, wineNote),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      wineNote.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _tintFor(ratingColor, theme, 0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${wineNote.rating} pts',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: ratingColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_month_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    wineNote.year.toString(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color:
                        theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  ),
                ],
              ),
              if (wineNote.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  wineNote.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _onSearchChanged(String value) {
    setState(() => _searchTerm = value.trim());
  }

  void _updateFilter(String value) {
    if (selectedRatingFilter == value) {
      return;
    }
    setState(() => selectedRatingFilter = value);
  }

  void _onSortChanged(String value) {
    if (value == selectedSortOption) {
      return;
    }
    setState(() => selectedSortOption = value);
    unawaited(_sortWineNotes(value));
  }

  List<WineNote> _applyFilters(List<WineNote> notes) {
    final filter = _ratingFilters.firstWhere(
      (option) => option.value == selectedRatingFilter,
    );
    final query = _searchTerm.toLowerCase();

    return notes.where((note) {
      final matchesRating = filter.matches(note);
      if (_searchTerm.isEmpty) {
        return matchesRating;
      }
      final matchesSearch = note.name.toLowerCase().contains(query) ||
          note.description.toLowerCase().contains(query) ||
          note.year.toString().contains(query);
      return matchesRating && matchesSearch;
    }).toList(growable: false);
  }

  Future<void> _sortWineNotes(String option, {bool persist = true}) async {
    switch (option) {
      case 'year':
        _notesList.sortWineNotesByYear(descending: true);
        break;
      case 'rating':
        _notesList.sortWineNotesByRating(descending: true);
        break;
      default:
        _notesList.sortWineNotesByName();
    }
    if (persist) {
      await _persistNotes();
    }
  }

  Future<void> _persistNotes() async {
    try {
      await NoteRepository.saveNotes(_notesList);
    } catch (e) {
      _showSnackBar('Failed to save notes: $e');
    }
  }

  Future<void> _navigateToAddNotePage(BuildContext context) async {
    final result = await Navigator.push<WineNote>(
      context,
      MaterialPageRoute(builder: (context) => const AddWineNotePage()),
    );

    if (result == null) {
      return;
    }

    _notesList.addWineNote(result);
    await _sortWineNotes(selectedSortOption, persist: false);
    await _persistNotes();
    _showSnackBar('Note added');
  }

  Future<void> _navigateToEditNotePage(
    BuildContext context,
    WineNote wineNote,
  ) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditWineNotePage(wineNote: wineNote),
      ),
    );

    if (result is WineNote) {
      _notesList.updateWineNote(result);
      await _sortWineNotes(selectedSortOption, persist: false);
      await _persistNotes();
      _showSnackBar('Note updated');
    } else if (result == true) {
      _notesList.deleteWineNote(wineNote.id);
      await _persistNotes();
      _showSnackBar('Note deleted');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Color _colorForRating(ThemeData theme, int rating) {
    if (rating >= 90) {
      return theme.colorScheme.primary;
    }
    if (rating >= 80) {
      return theme.colorScheme.secondary;
    }
    if (rating >= 70) {
      return theme.colorScheme.tertiary;
    }
    return theme.colorScheme.error;
  }

  Color _colorForFilter(ThemeData theme, String value) {
    switch (value) {
      case '90+':
        return theme.colorScheme.primary;
      case '80-89':
        return theme.colorScheme.secondary;
      case '70-79':
        return theme.colorScheme.tertiary;
      case 'sub70':
        return theme.colorScheme.error;
      default:
        return theme.colorScheme.primary;
    }
  }

  Color _tintFor(Color base, ThemeData theme, [double opacity = 0.16]) {
    return Color.alphaBlend(base.withOpacity(opacity), theme.colorScheme.surface);
  }

  Color _onColor(Color base) {
    return base.computeLuminance() > 0.55 ? Colors.black87 : Colors.white;
  }
}

class _NotesToolbarDelegate extends SliverPersistentHeaderDelegate {
  _NotesToolbarDelegate({required this.child, required this.height});

  final Widget child;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(covariant _NotesToolbarDelegate oldDelegate) {
    return oldDelegate.child != child || oldDelegate.height != height;
  }
}

class _SortOption {
  const _SortOption({required this.value, required this.label});

  final String value;
  final String label;
}

class _RatingFilterOption {
  const _RatingFilterOption({
    required this.value,
    required this.label,
    required this.matches,
  });

  final String value;
  final String label;
  final bool Function(WineNote note) matches;
}

const List<_SortOption> _sortOptions = <_SortOption>[
  _SortOption(value: 'name', label: 'Name (A-Z)'),
  _SortOption(value: 'year', label: 'Vintage'),
  _SortOption(value: 'rating', label: 'Rating'),
];

final List<_RatingFilterOption> _ratingFilters = <_RatingFilterOption>[
  _RatingFilterOption(
    value: 'all',
    label: 'All notes',
    matches: (note) => true,
  ),
  _RatingFilterOption(
    value: '90+',
    label: '90+ points',
    matches: (note) => note.rating >= 90,
  ),
  _RatingFilterOption(
    value: '80-89',
    label: '80-89 points',
    matches: (note) => note.rating >= 80 && note.rating <= 89,
  ),
  _RatingFilterOption(
    value: '70-79',
    label: '70-79 points',
    matches: (note) => note.rating >= 70 && note.rating <= 79,
  ),
  _RatingFilterOption(
    value: 'sub70',
    label: 'Under 70 points',
    matches: (note) => note.rating < 70,
  ),
];
