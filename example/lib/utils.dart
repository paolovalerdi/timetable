import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timetable/timetable.dart';

final _supportedLocales = [
  const Locale('de'),
  const Locale('en'),
  const Locale('es'),
  const Locale('fr'),
  const Locale('it'),
  const Locale('ja'),
  const Locale('pt'),
  const Locale('zh', 'CN'),
  const Locale('zh', 'TW'),
];

void initDebugOverlay() {
  // https://pub.dev/packages/debug_overlay
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      theme: _createTheme(Brightness.light),
      darkTheme: _createTheme(Brightness.dark),
      localizationsDelegates: [
        TimetableLocalizationsDelegate(),
        ...GlobalMaterialLocalizations.delegates,
      ],
      supportedLocales: _supportedLocales,
      home: SafeArea(child: Scaffold(body: child)),
    );
  }

  ThemeData _createTheme(Brightness brightness) {
    var theme = ThemeData(
      brightness: brightness,
      applyElevationOverlayColor: true,
      primaryColor: Colors.blue,
      primarySwatch: Colors.blue,
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
    theme = theme.copyWith(
      colorScheme: theme.colorScheme
          .copyWith(onBackground: theme.colorScheme.background.contrastColor),
      textTheme: theme.textTheme.copyWith(
        headline6:
            theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.normal),
      ),
      appBarTheme: theme.appBarTheme.copyWith(backwardsCompatibility: false),
    );

    // We want to extend Timetable behind the navigation bar.
    SystemChrome.setSystemUIOverlayStyle(
      brightness.contrastSystemUiOverlayStyle
          .copyWith(systemNavigationBarColor: Colors.transparent),
    );
    return theme;
  }
}
