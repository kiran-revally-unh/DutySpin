import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme.dart';
import 'continue_to_whose_turn_screen.dart';
import '../state/app_state.dart';

class OtpRequestScreen extends StatefulWidget {
  const OtpRequestScreen({super.key, required this.method});

  final AuthMethod method;

  @override
  State<OtpRequestScreen> createState() => _OtpRequestScreenState();
}

class _OtpRequestScreenState extends State<OtpRequestScreen> {
  final TextEditingController controller = TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmail = widget.method == AuthMethod.email;
    final value = controller.text.trim();
    final canContinue = isEmail ? value.contains('@') : value.length >= 7;
    final showError = value.isNotEmpty && !canContinue;

    final title = isEmail ? 'Enter your email' : 'Enter your phone';
    final hintText = isEmail ? 'name@example.com' : '(555) 123-4567';
    final keyboardType = isEmail ? TextInputType.emailAddress : TextInputType.phone;
    final prefixIcon = isEmail ? Icons.mail_outline_rounded : Icons.phone_iphone_rounded;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.text),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryMuted,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 34,
                              height: 34,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.text,
                            letterSpacing: -0.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "We'll send you a quick code to log in.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, color: AppTheme.textMuted, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 28),
                        TextField(
                          controller: controller,
                          autofocus: true,
                          keyboardType: keyboardType,
                          textCapitalization: TextCapitalization.none,
                          decoration: InputDecoration(
                            hintText: hintText,
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                            prefixIcon: Container(
                              margin: const EdgeInsets.only(left: 14, right: 10),
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(prefixIcon, color: AppTheme.textMuted, size: 22),
                            ),
                            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: AppTheme.border, width: 2),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(18),
                              borderSide: const BorderSide(color: AppTheme.welcomeCta, width: 2.4),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        if (showError) ...[
                          const SizedBox(height: 10),
                          Text(
                            isEmail ? 'Enter a valid email address.' : 'Enter a valid phone number.',
                            style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ],
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          height: 64,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.welcomeCta,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                            ),
                            onPressed: canContinue
                                ? () {
                                    context.read<AppState>().startOtpChallenge(destination: value);
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code sent')));
                                    Navigator.of(context).pushNamed(
                                      '/otpVerify',
                                      arguments: ({'method': widget.method, 'destination': value}),
                                    );
                                  }
                                : null,
                            child: const Text('Send code'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
