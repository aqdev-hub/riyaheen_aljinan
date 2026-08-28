import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_page.dart';
import 'features/quran/providers/quran_settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:                    Colors.transparent,
    statusBarIconBrightness:           Brightness.light,
    systemNavigationBarColor:          Colors.white,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  runApp(const RiyaheenApp());
}

class RiyaheenApp extends StatefulWidget {
  const RiyaheenApp({super.key});

  static RiyaheenAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<RiyaheenAppState>();

  @override
  State<RiyaheenApp> createState() => RiyaheenAppState();
}

class RiyaheenAppState extends State<RiyaheenApp> {
  ThemeMode _themeMode = ThemeMode.light;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    setState(() {
      _themeMode = isDark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  void setTheme(ThemeMode mode) {
    setState(() => _themeMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<QuranSettingsProvider>(
          create: (_) => QuranSettingsProvider()..load(),
        ),
      ],
      child: MaterialApp(
        title: 'رياحين الجنان',
        debugShowCheckedModeBanner: false,

        theme:     AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeMode,

        // ✅ الإصلاح الرئيسي: إضافة localizationsDelegates
        // هذا يحل خطأ "No MaterialLocalizations found"
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [
          Locale('ar', 'SA'),
          Locale('en', 'US'),
        ],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        // ✅ RTL عبر MaterialApp مباشرة بدلاً من Directionality wrapper منفصل
        // لأن Directionality بدون Localizations يسبب المشكلة
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },

        home: const HomePage(),
      ),
    );
  }
}
