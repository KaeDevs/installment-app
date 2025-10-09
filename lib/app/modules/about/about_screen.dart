import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_footer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Installment Tracker', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(height: 8),
                Text('A lightweight daily loan installment tracking tool with optional cloud sync via Firebase.'),
                const SizedBox(height: 24),
                const Text('Developer'),
                const SizedBox(height: 4),
                const Text('KaeDevs', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (auth.isSignedIn || auth.isGuest)
                  Text('Signed in as: ${auth.displayEmail ?? 'unknown'}'),
                const SizedBox(height: 24),
                const Text('Support / Donate'),
                const SizedBox(height: 8),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.coffee),
                    label: const Text('Buy me a coffee'),
                    onPressed: () => _openDonation(context),
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.favorite),
                    label: const Text('Donate'),
                    onPressed: () => _openDonation(context),
                  ),
                ]),
                const SizedBox(height: 32),
                Text('Version 1.0.0', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 32),
                // const AppFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDonation(BuildContext context) {
    // Placeholder: could integrate a payment link.
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Support the project'),
        content: InkWell(
          child: const Text(
            'https://buymeacoffee.com/kaedevs',
            style: TextStyle(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ),
          ),
          onTap: () async {
            final url = Uri.parse('https://buymeacoffee.com/kaedevs');
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}
