import 'package:flutter/material.dart';

import '../theme.dart';

enum AuthMethod { email, phone }

class ContinueToWhoseTurnScreen extends StatelessWidget {
  const ContinueToWhoseTurnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.primaryMuted,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/logo.png',
                    width: 44,
                    height: 44,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Image.asset(
                'assets/app_name.png',
                height: 22,
                fit: BoxFit.contain,
                semanticLabel: 'DutySpin',
              ),
              const SizedBox(height: 28),
              const Text(
                'Continue to DutySpin',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: AppTheme.text, letterSpacing: -0.6),
              ),
              const SizedBox(height: 14),
              const Text(
                "We'll send a one-time code.  No\npasswords.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: AppTheme.textMuted, height: 1.45, fontWeight: FontWeight.w500),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.welcomeCta,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  icon: const Icon(Icons.email_outlined),
                  label: const Text('Continue with Email'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/otpRequest', arguments: AuthMethod.email);
                  },
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 62,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.text,
                    side: const BorderSide(color: AppTheme.border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  icon: const Icon(Icons.phone_iphone_rounded),
                  label: const Text('Continue with Phone number'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/otpRequest', arguments: AuthMethod.phone);
                  },
                ),
              ),
              const SizedBox(height: 26),
            ],
          ),
        ),
      ),
    );
  }
}
