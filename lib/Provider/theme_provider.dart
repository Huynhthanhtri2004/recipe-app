import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  ThemeData get currentTheme {
    if (_isDarkMode) {
      return ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1E1E1E),
          elevation: 0,
        ),
        cardColor: const Color(0xFF1E1E1E),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
        ),
        colorScheme: const ColorScheme.dark().copyWith(
          secondary: const Color(0xFF568A9F),
        ),
      );
    } else {
      return ThemeData.light().copyWith(
        scaffoldBackgroundColor: const Color(0xfff1f1f7),
        appBarTheme: const AppBarTheme(
          color: Color(0xfff1f1f7),
          elevation: 0,
        ),
        cardColor: Colors.white,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
        ),
        colorScheme: const ColorScheme.light().copyWith(
          secondary: const Color(0xff568A9F),
        ),
      );
    }
  }
}