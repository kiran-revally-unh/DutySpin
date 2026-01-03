import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../components/avatar_chip.dart';
import '../state/app_state.dart';
import '../theme.dart';

class ChoreDetailScreen extends StatelessWidget {
  const ChoreDetailScreen({super.key, required this.choreId});

  final String choreId;

  String _formatTime(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('MMM d, h:mm a').format(d);
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final chore = state.chores.where((c) => c.id == choreId).isNotEmpty ? state.chores.firstWhere((c) => c.id == choreId) : null;

    if (chore == null) {
      return const Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Chore not found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
          ),
        ),
      );
    }

    final current = state.roommateById(chore.currentTurnRoommateId);
    final lastEntry = chore.history.isNotEmpty ? chore.history.first : null;
    final lastWho = lastEntry == null ? null : state.roommateById(lastEntry.completedByRoommateId);

    return Scaffold(
      appBar: AppBar(leading: const BackButton(), title: const Text('Chore Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMuted,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                alignment: Alignment.center,
                child: const Text('✓', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primary)),
              ),
              const SizedBox(height: 18),
              Text(chore.title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
              const SizedBox(height: 8),
              Text(
                chore.repeatText ?? 'A shared chore with a simple rotation.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text('Up Next: ${current?.name ?? '—'}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
                      const SizedBox(height: 6),
                      const Text('It’s their turn to keep things moving.', style: TextStyle(color: AppTheme.textMuted)),
                      const SizedBox(height: 16),
                      AvatarChip(name: current?.name ?? '—', size: 64),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            try {
                              await context.read<AppState>().markChoreDone(chore.id);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                          child: const Text('Mark Complete'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('A simple reminder can go a long way.'))),
                        child: const Text('Send a gentle nudge', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: AppTheme.warningBg,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lastEntry == null ? 'No history yet' : 'Last completed',
                        style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.warningText),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        lastEntry == null ? 'The first completion will show up here.' : '${lastWho?.name ?? 'Someone'} • ${_formatTime(lastEntry.completedAtIso)}',
                        style: const TextStyle(color: AppTheme.warningText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('RECENT ACTIVITY', style: TextStyle(fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
              ),
              const SizedBox(height: 10),
              ...chore.history.take(6).map((h) {
                final who = state.roommateById(h.completedByRoommateId);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${who?.name ?? 'Someone'} completed', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.text)),
                          const SizedBox(height: 4),
                          Text(_formatTime(h.completedAtIso), style: const TextStyle(color: AppTheme.textMuted)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
