import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _headerDate() {
    final d = DateTime.now();
    final weekday = DateFormat('EEEE').format(d).toUpperCase();
    final rest = DateFormat('MMM d').format(d).toUpperCase();
    return '$weekday, $rest';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final you = state.roommates.where((r) => r.isYou).isNotEmpty ? state.roommates.firstWhere((r) => r.isYou) : null;
    final youId = you?.id;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ListView(
        children: [
          const Text('GOOD MORNING', style: TextStyle(fontSize: 13, letterSpacing: 1.6, fontWeight: FontWeight.w900, color: AppTheme.textMuted)),
          const SizedBox(height: 4),
          Text(you?.name ?? 'You', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 10),
          Text(_headerDate(), style: const TextStyle(fontSize: 13, letterSpacing: 1.6, fontWeight: FontWeight.w900, color: AppTheme.primary)),
          const SizedBox(height: 10),
          Text('${state.chores.length} chores due today', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 24),
          if (state.chores.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No chores yet', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
                    SizedBox(height: 6),
                    Text('Add a couple to get started.', style: TextStyle(color: AppTheme.textMuted)),
                  ],
                ),
              ),
            )
          else
            ...state.chores.map((c) {
              final current = state.roommateById(c.currentTurnRoommateId);
              final next = state.roommateById(c.nextTurnRoommateId);
              final yourTurn = youId != null && c.currentTurnRoommateId == youId;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.text)),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${yourTurn ? 'Your turn' : "${current?.name ?? 'Someone'}’s turn"} • Next: ${next?.name ?? '—'}',
                                    style: const TextStyle(color: AppTheme.textMuted),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              height: 44,
                              child: ElevatedButton(
                                onPressed: yourTurn
                                    ? () async {
                                        try {
                                          await context.read<AppState>().markChoreDone(c.id);
                                        } catch (e) {
                                          if (!context.mounted) return;
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                                        }
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(110, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                ),
                                child: Text(yourTurn ? 'Done' : 'Waiting'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/choreDetail', arguments: c.id),
                          child: const Text('View details', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
