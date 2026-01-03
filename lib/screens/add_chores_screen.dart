import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class AddChoresScreen extends StatefulWidget {
  const AddChoresScreen({super.key});

  @override
  State<AddChoresScreen> createState() => _AddChoresScreenState();
}

class _AddChoresScreenState extends State<AddChoresScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canFinish = state.chores.isNotEmpty;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add chores', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
              const SizedBox(height: 10),
              const Text(
                'Add a few essentials to get started. You can always add more later.',
                style: TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: const InputDecoration(hintText: 'e.g. Take out trash'),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 58,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        final t = controller.text.trim();
                        if (t.isEmpty) return;
                        try {
                          await context.read<AppState>().addChore(t);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          return;
                        }
                        controller.clear();
                        setState(() {});
                      },
                      child: const Text('+', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: state.chores.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final c = state.chores[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.title, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.text)),
                            TextButton(
                              onPressed: () async {
                                try {
                                  await context.read<AppState>().removeChore(c.id);
                                } catch (e) {
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                }
                              },
                              child: const Text('Remove', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: canFinish
                    ? () async {
                        await context.read<AppState>().setOnboardingComplete(true);
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil('/main', (r) => false);
                      }
                    : null,
                child: const Text('Finish Setup'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
