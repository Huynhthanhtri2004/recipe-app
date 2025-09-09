import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:recipe_app/Provider/auth_provider.dart' as my_auth; // alias để tránh trùng tên
import 'package:recipe_app/Provider/favorite_provider.dart';
import 'package:recipe_app/Provider/quantity.dart';
import 'package:recipe_app/Provider/theme_provider.dart';
import 'package:recipe_app/Views/app_main_screen.dart';
import 'package:recipe_app/Views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => my_auth.AuthProvider()), // sử dụng alias
        ChangeNotifierProvider(create: (_) => FavoriteProvider()),
        ChangeNotifierProvider(create: (_) => QuantityProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: themeProvider.currentTheme,
            home: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  final user = snapshot.data;
                  if (user == null) {
                    return const LoginScreen();
                  }
                  return const AppMainScreen();
                }
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
