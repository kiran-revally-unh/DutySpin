import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/avatar_chip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'create_or_join_screen.dart';

class RoommatesScreen extends StatelessWidget {
  const RoommatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final room = state.room;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ListView(
        children: [
          const Text('Roommates', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
          const SizedBox(height: 10),
          Text(
            room == null ? 'You are not in a room yet.' : (room.name),
            style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          if (room == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('No room', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.text)),
                    const SizedBox(height: 6),
                    const Text('Create or join a room to start sharing chores.', style: TextStyle(color: AppTheme.textMuted)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.welcomeCta),
                        onPressed: () => Navigator.of(context).pushNamed('/createOrJoin'),
                        child: const Text('Create or Join'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Invite code', style: TextStyle(fontWeight: FontWeight.w900, color: AppTheme.text)),
                    const SizedBox(height: 6),
                    Text(room.inviteCode ?? '—', style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w800, letterSpacing: 1.4)),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copy/share coming soon.')));
                        },
                        child: const Text('Share invite'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            ...state.roommates.map(
              (rm) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        AvatarChip(name: rm.name),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(rm.name, style: const TextStyle(fontWeight: FontWeight.w900, color: AppTheme.text)),
                              const SizedBox(height: 2),
                              Text(rm.isYou ? 'You' : (rm.email ?? 'Roommate'), style: const TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.welcomeCta),
                onPressed: () {
                  Navigator.of(context).pushNamed('/setupRoom', arguments: const SetupRoomArgs.create());
                },
                child: const Text('Manage roommates'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
