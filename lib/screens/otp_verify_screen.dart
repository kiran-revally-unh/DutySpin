import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import '../theme.dart';
import 'continue_to_whose_turn_screen.dart';

class OtpVerifyArgs {
  const OtpVerifyArgs({required this.method, required this.destination});

  final AuthMethod method;
  final String destination;
}

class OtpVerifyScreen extends StatefulWidget {
  const OtpVerifyScreen({super.key, required this.args});

  final OtpVerifyArgs args;

  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final TextEditingController code = TextEditingController();

  String? error;
  int attemptsLeft = 3;
  DateTime? _lastResendAt;

  bool get _canResend {
    final last = _lastResendAt;
    if (last == null) return true;
    return DateTime.now().difference(last) >= const Duration(seconds: 30);
  }

  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = code.text.trim();
    final canVerify = c.length == 6;

    final state = context.watch<AppState>();
    final remaining = state.otpTimeRemaining;
    final expired = remaining == Duration.zero;

    return Scaffold(
      appBar: AppBar(leading: const BackButton()),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the code',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -0.3),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a 6-digit code to ${widget.args.destination}.',
                style: const TextStyle(fontSize: 16, color: AppTheme.textMuted, height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                expired
                    ? 'Code expired. Please resend.'
                    : (remaining == null ? '' : 'Expires in ${remaining.inMinutes}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'),
                style: TextStyle(fontSize: 14, color: expired ? Colors.redAccent : AppTheme.textMuted, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 22),
              TextField(
                controller: code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: const InputDecoration(hintText: '123456', counterText: ''),
                onChanged: (_) => setState(() {
                  error = null;
                }),
              ),
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w800)),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Attempts left: $attemptsLeft',
                    style: const TextStyle(color: AppTheme.textMuted, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _canResend
                        ? () {
                            context.read<AppState>().startOtpChallenge(destination: widget.args.destination);
                            setState(() {
                              _lastResendAt = DateTime.now();
                              attemptsLeft = 3;
                              error = null;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('New code sent')));
                          }
                        : null,
                    child: Text(
                      _canResend ? 'Resend code' : 'Resend in 30s',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.welcomeCta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  onPressed: (canVerify && attemptsLeft > 0 && !expired)
                      ? () async {
                          final ok = context.read<AppState>().verifyOtpCode(c);
                          if (!ok) {
                            setState(() {
                              attemptsLeft = (attemptsLeft - 1).clamp(0, 3);
                              error = attemptsLeft <= 1 ? 'Too many attempts. Please resend.' : 'Incorrect code. Try again.';
                            });
                            return;
                          }

                          context.read<AppState>().setAuthenticated(true);
                          context.read<AppState>().setOnboardingComplete(true);
                          context.read<AppState>().clearOtpChallenge();
                          if (!context.mounted) return;
                          final hasRoom = context.read<AppState>().room != null;
                          Navigator.of(context).pushNamedAndRemoveUntil(hasRoom ? '/main' : '/createOrJoin', (r) => false);
                        }
                      : null,
                  child: const Text('Verify'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
