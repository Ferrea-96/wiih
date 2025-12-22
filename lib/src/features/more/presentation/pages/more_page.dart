import 'package:flutter/material.dart';

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
}
