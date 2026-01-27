import 'package:flutter/material.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/app_theme.dart';
import 'package:flutter_tomato_leaf_disease_detector/core/theme_notifier.dart';

import 'package:flutter_tomato_leaf_disease_detector/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  @override
  void initState() {
    super.initState();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Leaf Guard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: SplashScreen(themeNotifier: _themeNotifier),
    );
  }
}
