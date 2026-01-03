import 'package:flutter/material.dart';

import '../theme.dart';

class CreateOrJoinScreen extends StatefulWidget {
  const CreateOrJoinScreen({super.key});

  @override
  State<CreateOrJoinScreen> createState() => _CreateOrJoinScreenState();
}

class _CreateOrJoinScreenState extends State<CreateOrJoinScreen> {
  bool showJoin = false;
  final TextEditingController inviteController = TextEditingController();

  @override
  void dispose() {
    inviteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invite = inviteController.text.trim();
    final canJoin = invite.length >= 3;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 36),
                child: Column(
                  children: [
                    const SizedBox(height: 6),
                    const Text(
                      'Create or Join a Room',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox(
                                height: 40,
                                width: 40,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).maybePop(),
                                  icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.text),
                                  tooltip: 'Back',
                                ),
                              ),
                              const Spacer(),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppTheme.welcomeCta,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: SizedBox(
                              height: 220,
                              width: double.infinity,
                              child: Image.asset(
                                'assets/welcome_hero.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          const Text(
                            'Welcome Home',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.text,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Organize your chores and build trust\nwith your housemates.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.45, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 20),
                          _ActionTile(
                            variant: _ActionTileVariant.primary,
                            title: 'Create a New Room',
                            subtitle: "I'm setting up a new household.",
                            onTap: () {
                              Navigator.of(context).pushNamed('/setupRoom', arguments: const SetupRoomArgs.create());
                            },
                            trailing: _CircleIcon(
                              background: Colors.white.withValues(alpha: 0.20),
                              child: Stack(
                                alignment: Alignment.center,
                                children: const [
                                  Icon(Icons.home_rounded, size: 22, color: Colors.white),
                                  Positioned(
                                    right: 3,
                                    bottom: 3,
                                    child: Icon(Icons.add_circle_rounded, size: 14, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _ActionTile(
                            variant: _ActionTileVariant.secondary,
                            title: 'Join a Room',
                            subtitle: 'I have an invite code or link.',
                            onTap: () => setState(() => showJoin = true),
                            trailing: const _CircleIcon(
                              background: AppTheme.primaryMuted,
                              child: Icon(Icons.qr_code_rounded, size: 22, color: AppTheme.welcomeCta),
                            ),
                          ),
                          AnimatedSize(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeInOut,
                            child: showJoin
                                ? Padding(
                                    padding: const EdgeInsets.only(top: 14),
                                    child: Column(
                                      children: [
                                        TextField(
                                          controller: inviteController,
                                          textCapitalization: TextCapitalization.characters,
                                          decoration: const InputDecoration(hintText: 'Invite code'),
                                          onChanged: (_) => setState(() {}),
                                        ),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          height: 52,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppTheme.welcomeCta,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                                              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                                            ),
                                            onPressed: canJoin
                                                ? () {
                                                    Navigator.of(context).pushNamed(
                                                      '/setupRoom',
                                                      arguments: SetupRoomArgs.join(inviteController.text.trim()),
                                                    );
                                                  }
                                                : null,
                                            child: const Text('Join'),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 6,
                            children: [
                              const Text(
                                'Already have an account?',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pushNamedAndRemoveUntil('/continue', (r) => false);
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.welcomeCta,
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text('Log in', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum _ActionTileVariant { primary, secondary }

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.variant,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  final _ActionTileVariant variant;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == _ActionTileVariant.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary ? AppTheme.welcomeCta : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: isPrimary ? Colors.transparent : AppTheme.border),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: AppTheme.welcomeCta.withValues(alpha: 0.28),
                      blurRadius: 22,
                      offset: const Offset(0, 14),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 16,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isPrimary ? Colors.white : AppTheme.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: isPrimary ? Colors.white.withValues(alpha: 0.92) : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.background, required this.child});

  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

class SetupRoomArgs {
  const SetupRoomArgs._({required this.mode, this.inviteCode});

  final String mode; // create | join
  final String? inviteCode;

  const SetupRoomArgs.create() : this._(mode: 'create');

  factory SetupRoomArgs.join(String code) => SetupRoomArgs._(mode: 'join', inviteCode: code);
}
