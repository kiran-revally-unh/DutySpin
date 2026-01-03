import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/avatar_chip.dart';
import '../state/app_state.dart';
import '../theme.dart';
import 'create_or_join_screen.dart';

class SetupRoomScreen extends StatefulWidget {
  const SetupRoomScreen({super.key, required this.args});

  final SetupRoomArgs args;

  @override
  State<SetupRoomScreen> createState() => _SetupRoomScreenState();
}

class _SetupRoomScreenState extends State<SetupRoomScreen> {
  final TextEditingController roomName = TextEditingController();
  final TextEditingController roommateName = TextEditingController();
  final TextEditingController roommateEmail = TextEditingController();

  bool _initialized = false;

  @override
  void dispose() {
    roomName.dispose();
    roommateName.dispose();
    roommateEmail.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _initialized = true;

    // Avoid notifying listeners during the build phase.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final state = context.read<AppState>();

      // This screen is used both during onboarding and later from Settings.
      // Avoid unintentionally recreating/joining a room if one already exists.
      if (state.room == null) {
        if (widget.args.mode == 'create') {
          await state.createRoom(state.room?.name ?? 'My Home');
        } else {
          await state.joinRoom(widget.args.inviteCode ?? '');
        }
      }

      if (!mounted) return;
      roomName.text = state.room?.name ?? '';
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final roommates = state.roommates;
    final canContinue = (roomName.text.trim().isNotEmpty) && roommates.isNotEmpty;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Let’s name your space', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text)),
                const SizedBox(height: 10),
                const Text(
                  'Give your home a nickname and add the people sharing the load.',
                  style: TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.4),
                ),
                const SizedBox(height: 24),
                const Text(
                  'ROOM NAME',
                  style: TextStyle(fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: roomName,
                  decoration: const InputDecoration(hintText: 'e.g. Our Apartment'),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (t) => context.read<AppState>().setRoomName(t),
                ),
                const SizedBox(height: 24),
                const Text(
                  'WHO LIVES HERE?',
                  style: TextStyle(fontSize: 13, letterSpacing: 1, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: roommateName,
                        decoration: const InputDecoration(hintText: 'Name'),
                        textCapitalization: TextCapitalization.words,
                      ),
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 98,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () async {
                          final name = roommateName.text.trim();
                          final email = roommateEmail.text.trim();
                          if (name.isEmpty) return;
                          await context.read<AppState>().addRoommate(name: name, email: email.isEmpty ? null : email);
                          roommateName.clear();
                          roommateEmail.clear();
                          setState(() {});
                        },
                        child: const Text('Add'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: roommateEmail,
                  decoration: const InputDecoration(hintText: 'Email (optional)'),
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),
                ...roommates.map(
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
                                  Text(rm.name, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.text)),
                                  const SizedBox(height: 2),
                                  Text(rm.isYou ? 'Admin' : (rm.email ?? 'Roommate'), style: const TextStyle(color: AppTheme.textMuted)),
                                ],
                              ),
                            ),
                            if (!rm.isYou)
                              TextButton(
                                onPressed: () => context.read<AppState>().removeRoommate(rm.id),
                                child: const Text('Remove', style: TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700)),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: canContinue
                      ? () {
                          Navigator.of(context).pushNamed('/addChores');
                        }
                      : null,
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
