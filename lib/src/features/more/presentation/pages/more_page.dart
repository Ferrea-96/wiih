import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wiih/src/features/auth/data/auth_service.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/cellar/data/wine_repository.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';
import 'package:wiih/src/features/more/presentation/services/csv_utils.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _sectionTitle('App'),
        _card(
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About WIIH'),
              subtitle: const Text('Version, credits, and legal info'),
              onTap: () => _showAbout(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Settings'),
        _card(
          children: [
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Preferences'),
              subtitle: const Text('Notifications and storage'),
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Data'),
        _card(
          children: [
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Export cellar as CSV'),
              subtitle: const Text('Copy your wines to the clipboard'),
              onTap: () => _exportCsv(context),
            ),
            ListTile(
              leading: const Icon(Icons.upload_outlined),
              title: const Text('Import cellar from CSV'),
              subtitle: const Text('Add wines from a CSV file'),
              onTap: () => _importCsv(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Support'),
        _card(
          children: [
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: const Text('Help & feedback'),
              subtitle: const Text('Get in touch with the team'),
              onTap: () => _showComingSoon(context),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle('Account'),
        _card(
          children: [
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: AuthService.signOut,
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: Colors.white.withValues(alpha: 0.9),
      child: Column(children: children),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'WIIH',
      applicationLegalese: 'Built for your cellar, focused on what matters.',
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('More details coming soon.')),
    );
  }

  Future<void> _exportCsv(BuildContext context) async {
    final wineList = Provider.of<WineList>(context, listen: false);
    final wines = wineList.allWines;

    if (wines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No wines to export yet.')),
      );
      return;
    }

    final csv = buildCsv(wines);
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV copied for ${wines.length} wines.')),
      );
      return;
    }

    final file = await _writeCsvFile(csv);
    if (!context.mounted) return;
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WIIH cellar export',
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV ready to share for ${wines.length} wines.')),
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sharing not available, CSV copied for ${wines.length} wines.',
          ),
        ),
      );
    }
  }

  Future<void> _importCsv(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final selected = result.files.single;
    final bytes = selected.bytes ??
        (selected.path != null ? await File(selected.path!).readAsBytes() : null);
    if (bytes == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Unable to read the CSV file.')),
      );
      return;
    }

    var csvText = utf8.decode(bytes);
    if (csvText.isNotEmpty && csvText.codeUnitAt(0) == 0xFEFF) {
      csvText = csvText.substring(1);
    }
    final rows = parseCsvRows(csvText);
    if (rows.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('CSV file is empty.')),
      );
      return;
    }

    final dataRows = stripHeader(rows);
    if (dataRows.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('CSV file has no data rows.')),
      );
      return;
    }

    final progress = ValueNotifier<_ImportProgress>(
      _ImportProgress(total: dataRows.length),
    );
    final navigator = Navigator.of(context);

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return ValueListenableBuilder<_ImportProgress>(
          valueListenable: progress,
          builder: (context, value, _) {
            return AlertDialog(
              title: const Text('Importing wines'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Imported ${value.imported} of ${value.total} entries',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${value.failed} failed',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    final wineList = Provider.of<WineList>(context, listen: false);
    final existingIds = wineList.allWines.map((wine) => wine.id).toSet();
    var nextId = existingIds.isEmpty ? 1 : existingIds.reduce(maxInt) + 1;
    final imported = <Wine>[];
    final failedRows = <List<String>>[];
    final failedReasons = <String>[];

    for (final row in dataRows) {
      final parsed = parseWineRow(row, existingIds, nextId);
      if (parsed.wine == null) {
        failedRows.add(row);
        failedReasons.add(parsed.error ?? 'Invalid row');
        progress.value = progress.value.copyWith(
          processed: progress.value.processed + 1,
          failed: progress.value.failed + 1,
        );
        continue;
      }
      existingIds.add(parsed.wine!.id);
      nextId = parsed.wine!.id >= nextId ? parsed.wine!.id + 1 : nextId;
      imported.add(parsed.wine!);
      progress.value = progress.value.copyWith(
        processed: progress.value.processed + 1,
        imported: progress.value.imported + 1,
      );
    }

    if (imported.isNotEmpty) {
      final updated = [...wineList.allWines, ...imported];
      wineList.loadWines(updated);
      await WineRepository.saveWines(wineList);
    }

    if (navigator.canPop()) {
      navigator.pop();
    }

    if (failedRows.isNotEmpty) {
      final failedCsv = buildFailedCsv(
        failedRows: failedRows,
        failedReasons: failedReasons,
      );
      await _shareFailedCsv(context, failedCsv, failedRows.length);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          'Imported ${imported.length} wines. '
          '${failedRows.length} failed.',
        ),
      ),
    );
  }

  Future<File> _writeCsvFile(String csv, {String suffix = ''}) async {
    final directory = await getTemporaryDirectory();
    final timestamp = _timestampForFilename(DateTime.now());
    final file = File(
      '${directory.path}/wiih_cellar_${timestamp}${suffix.isEmpty ? '' : '_$suffix'}.csv',
    );
    await file.writeAsString(csv);
    return file;
  }

  String _timestampForFilename(DateTime dateTime) {
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final second = dateTime.second.toString().padLeft(2, '0');
    return '${dateTime.year}$month${day}_$hour$minute$second';
  }

  Future<void> _shareFailedCsv(
    BuildContext context,
    String csv,
    int failedCount,
  ) async {
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed rows CSV copied ($failedCount).')),
      );
      return;
    }

    final file = await _writeCsvFile(csv, suffix: 'error');
    if (!context.mounted) return;
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WIIH import failures ($failedCount)',
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: csv));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed rows CSV copied ($failedCount).'),
        ),
      );
    }
  }

}

class _ImportProgress {
  const _ImportProgress({
    required this.total,
    this.processed = 0,
    this.imported = 0,
    this.failed = 0,
  });

  final int total;
  final int processed;
  final int imported;
  final int failed;

  _ImportProgress copyWith({
    int? total,
    int? processed,
    int? imported,
    int? failed,
  }) {
    return _ImportProgress(
      total: total ?? this.total,
      processed: processed ?? this.processed,
      imported: imported ?? this.imported,
      failed: failed ?? this.failed,
    );
  }
}
