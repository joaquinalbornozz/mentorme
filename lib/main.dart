import 'package:cloudinary_flutter/cloudinary_object.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mentorme/src/services/firebase_options.dart';
import 'package:mentorme/src/pages/welcome_page.dart';
import 'package:mentorme/src/routes/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mentorme/src/utils/cartnotifier.dart';
import 'package:provider/provider.dart';
import 'package:cloudinary_flutter/cloudinary_context.dart';
import 'package:cloudinary_flutter/image/cld_image.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Cloudinary cloudinary= CloudinaryObject.fromCloudName(cloudName: "dci0bezbf");

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