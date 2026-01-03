import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

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

    final events = <({String choreTitle, String who, String whenIso})>[];
    for (final c in state.chores) {
      for (final h in c.history) {
        final who = state.roommateById(h.completedByRoommateId)?.name ?? 'Someone';
        events.add((choreTitle: c.title, who: who, whenIso: h.completedAtIso));
      }
    }

    events.sort((a, b) => b.whenIso.compareTo(a.whenIso));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ListView(
        children: [
          const Text('History', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 10),
          const Text('Recent activity across the whole room.', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
          const SizedBox(height: 18),
          if (events.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No history yet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.text)),
                    SizedBox(height: 6),
                    Text('Completed chores will show up here.', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            )
          else
            ...events.take(80).map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${e.who} completed', style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.text)),
                            const SizedBox(height: 4),
                            Text(e.choreTitle, style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(_formatTime(e.whenIso), style: const TextStyle(color: AppTheme.textMuted)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
