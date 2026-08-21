import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.credit_card, color: Theme.of(context).colorScheme.primary, size: 34),
                ),
                const SizedBox(height: 16),
                const Text('TrimIt', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snapshot) {
                    final version = snapshot.data?.version ?? '';
                    return Text(
                      version.isEmpty ? '' : 'Version $version',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          const _SectionTitle('About'),
          const Text(
            'TrimIt helps you track subscriptions, see what you\'re really spending, '
            'and get reminded before renewals catch you off guard. All your data stays '
            'on your device — TrimIt does not upload your subscriptions anywhere.',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Frequently asked questions'),
          const _FaqItem(
            question: 'Is my data private?',
            answer: 'Yes. Your subscriptions, wallets, and account details are stored only on your device. The only outside connection TrimIt makes is to fetch current currency exchange rates.',
          ),
          const _FaqItem(
            question: 'What happens if I uninstall the app?',
            answer: 'All local data is removed with the app, unless you\'ve made a backup (see Settings > Data Backup & Restore).',
          ),
          const _FaqItem(
            question: 'Why did a notification not arrive?',
            answer: 'Make sure notification permissions are enabled for TrimIt in your phone\'s system settings, and that battery optimization isn\'t restricting the app.',
          ),
          const SizedBox(height: 24),
          const _SectionTitle('Contact'),
          const Text(
            'For support or feedback, reach out via the app store listing once TrimIt is published.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;
  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 4),
          Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }
}