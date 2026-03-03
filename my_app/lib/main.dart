import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'constants/app_theme.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authService = AuthService();
  await authService.init();
  runApp(OakwoodClimbingApp(authService: authService));
}

class OakwoodClimbingApp extends StatelessWidget {
  final AuthService authService;

  const OakwoodClimbingApp({super.key, required this.authService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        Provider(
          create: (_) => ApiService(() => authService.token),
        ),
      ],
      child: MaterialApp(
        title: 'Oakwood Climbing Gym',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: Consumer<AuthService>(
          builder: (context, auth, _) {
            if (auth.isAuthenticated) {
              return const HomeScreen();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
