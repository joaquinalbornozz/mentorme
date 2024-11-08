import 'package:flutter/material.dart';
import 'package:mentorme/src/pages/welcome_page.dart';
import 'package:mentorme/src/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mentorme/src/utils/cartnotifier.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartNotifier(), // Proveedor para toda la app
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MentorMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('es'), // Spanish
      ],
      initialRoute: 'home',
      routes: getAplicationRoutes(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute(
            builder: (BuildContext context) => const WelcomePage());
      },
      // home: ChangeNotifierProvider(
      //   create: (context) => CartNotifier(),
      //   child: const HomePage(),
      // ),
    );
  }
}