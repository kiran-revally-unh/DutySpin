import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

import 'screens/add_chores_screen.dart';
import 'screens/chore_detail_screen.dart';
import 'screens/continue_to_whose_turn_screen.dart';
import 'screens/create_or_join_screen.dart';
import 'screens/main_shell.dart';
import 'screens/otp_request_screen.dart';
import 'screens/otp_verify_screen.dart';
import 'screens/setup_room_screen.dart';
import 'screens/upgrade_screen.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(DutySpinApp(firebaseReady: firebaseReady));
}

class DutySpinApp extends StatelessWidget {
  const DutySpinApp({super.key, required this.firebaseReady});

  final bool firebaseReady;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(firebaseReady: firebaseReady),
      child: MaterialApp(
        title: 'DutySpin',
        theme: AppTheme.theme(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const _Bootstrap());
            case '/continue':
              return MaterialPageRoute(builder: (_) => const ContinueToWhoseTurnScreen());
            case '/otpRequest':
              final method = (settings.arguments as AuthMethod?) ?? AuthMethod.email;
              return MaterialPageRoute(builder: (_) => OtpRequestScreen(method: method));
            case '/otpVerify':
              final raw = settings.arguments;
              if (raw is OtpVerifyArgs) {
                return MaterialPageRoute(builder: (_) => OtpVerifyScreen(args: raw));
              }
              if (raw is Map) {
                final method = (raw['method'] as AuthMethod?) ?? AuthMethod.email;
                final dest = (raw['destination'] as String?) ?? '';
                return MaterialPageRoute(builder: (_) => OtpVerifyScreen(args: OtpVerifyArgs(method: method, destination: dest)));
              }
              return MaterialPageRoute(builder: (_) => OtpVerifyScreen(args: const OtpVerifyArgs(method: AuthMethod.email, destination: '')));
            case '/createOrJoin':
              return MaterialPageRoute(builder: (_) => const CreateOrJoinScreen());
            case '/setupRoom':
              final args = settings.arguments as SetupRoomArgs?;
              return MaterialPageRoute(
                builder: (_) => SetupRoomScreen(args: args ?? const SetupRoomArgs.create()),
              );
            case '/addChores':
              return MaterialPageRoute(builder: (_) => const AddChoresScreen());
            case '/main':
              return MaterialPageRoute(builder: (_) => const MainShell());
            case '/choreDetail':
              final id = settings.arguments as String?;
              return MaterialPageRoute(builder: (_) => ChoreDetailScreen(choreId: id ?? ''));
            case '/upgrade':
              return MaterialPageRoute(builder: (_) => const UpgradeScreen());
            default:
              return MaterialPageRoute(builder: (_) => const WelcomeScreen());
          }
        },
      ),
    );
  }
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();

  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppState>().hydrate();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.hydrated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // Session-only auth: require OTP each time the app starts.
    if (!state.authenticated) return const WelcomeScreen();
    if (state.room != null) return const MainShell();
    return const CreateOrJoinScreen();
  }
}
