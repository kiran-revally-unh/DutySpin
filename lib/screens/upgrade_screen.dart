import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class UpgradeScreen extends StatelessWidget {
  const UpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Upgrade to Pro'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Simple pricing for a peaceful home',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -0.4),
              ),
              const SizedBox(height: 12),
              const Text(
                'Remove limits and keep your household in sync for the long run.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Text('LIFETIME ACCESS', style: TextStyle(letterSpacing: 1.4, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                      const SizedBox(height: 10),
                      const Text('4.99', style: TextStyle(fontSize: 56, fontWeight: FontWeight.w900, color: AppTheme.text)),
                      const SizedBox(height: 6),
                      const Text('One-time payment. No subscriptions.', style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      const Divider(height: 1, thickness: 1, color: AppTheme.border),
                      const SizedBox(height: 12),
                      const _Bullet(title: 'Unlimited rooms', sub: 'Manage every space in your home.'),
                      const _Bullet(title: 'Unlimited chores', sub: 'Add as many tasks as you need.'),
                      Opacity(
                        opacity: state.proUnlocked ? 1 : 0.45,
                        child: const _Bullet(title: 'History & schedule', sub: 'See who did what, when.'),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.proUnlocked
                      ? null
                      : () async {
                          await context.read<AppState>().setProUnlocked(true);
                          if (!context.mounted) return;
                          showDialog<void>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Pro unlocked'),
                              content: const Text('Thanks for supporting DutySpin.'),
                              actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
                            ),
                          );
                        },
                  child: Text(state.proUnlocked ? 'Unlocked' : 'Unlock Lifetime Access'),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Restore Purchase   •   Terms of Service', style: TextStyle(color: AppTheme.textMuted)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.title, required this.sub});

  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.text)),
                const SizedBox(height: 4),
                Text(sub, style: const TextStyle(color: AppTheme.textMuted)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
