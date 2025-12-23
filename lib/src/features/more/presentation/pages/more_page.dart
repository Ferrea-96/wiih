import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wiih/src/features/auth/data/auth_service.dart';
import 'package:wiih/src/features/cellar/domain/models/wine.dart';
import 'package:wiih/src/features/cellar/presentation/state/wine_list.dart';

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
              subtitle: const Text('Coming soon'),
              onTap: () => _showComingSoon(context),
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
      color: Colors.white.withOpacity(0.9),
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

    final csv = _buildCsv(wines);
    if (kIsWeb) {
      await Clipboard.setData(ClipboardData(text: csv));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV copied for ${wines.length} wines.')),
      );
      return;
    }

    final file = await _writeCsvFile(csv);
    try {
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WIIH cellar export',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('CSV ready to share for ${wines.length} wines.')),
      );
    } on MissingPluginException {
      await Clipboard.setData(ClipboardData(text: csv));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Sharing not available, CSV copied for ${wines.length} wines.',
          ),
        ),
      );
    }
  }

  Future<File> _writeCsvFile(String csv) async {
    final directory = await getTemporaryDirectory();
    final timestamp = _timestampForFilename(DateTime.now());
    final file =
        File('${directory.path}/wiih_cellar_$timestamp.csv');
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

  String _buildCsv(List<Wine> wines) {
    final buffer = StringBuffer();
    buffer.writeln(
      'id,name,type,winery,country,grapeVariety,year,price,bottleCount,imageUrl',
    );

    for (final wine in wines) {
      buffer.writeln(
        [
          wine.id.toString(),
          _escapeCsv(wine.name),
          _escapeCsv(wine.type),
          _escapeCsv(wine.winery),
          _escapeCsv(wine.country),
          _escapeCsv(wine.grapeVariety),
          wine.year.toString(),
          wine.price.toString(),
          wine.bottleCount.toString(),
          _escapeCsv(wine.imageUrl ?? ''),
        ].join(','),
      );
    }

    return buffer.toString();
  }

  String _escapeCsv(String value) {
    final escaped = value.replaceAll('"', '""');
    final needsQuotes = escaped.contains(',') ||
        escaped.contains('\n') ||
        escaped.contains('\r') ||
        escaped.contains('"');
    return needsQuotes ? '"$escaped"' : escaped;
  }
}
