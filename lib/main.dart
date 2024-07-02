import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'pages/navigation_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MaterialApp(
        theme: ThemeData(
          primaryColor: Colors.green[900], // Dunkles Grün als Primärfarbe
          scaffoldBackgroundColor:
              Colors.green[900], // Hintergrundfarbe des Screens
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white), // Widgets Text in weiß
            bodyMedium: TextStyle(color: Colors.white), // Widgets Text in weiß
            displayLarge:
                TextStyle(color: Colors.white), // Widgets Text in weiß
            displayMedium:
                TextStyle(color: Colors.white), // Widgets Text in weiß
            displaySmall:
                TextStyle(color: Colors.white), // Widgets Text in weiß
            headlineMedium:
                TextStyle(color: Colors.white), // Widgets Text in weiß
            headlineSmall:
                TextStyle(color: Colors.white), // Widgets Text in weiß
            titleLarge: TextStyle(color: Colors.white), // Widgets Text in weiß
            titleMedium: TextStyle(color: Colors.white), // Widgets Text in weiß
            titleSmall: TextStyle(color: Colors.white), // Widgets Text in weiß
            labelLarge: TextStyle(color: Colors.white), // Widgets Text in weiß
            bodySmall: TextStyle(
                color: Colors.white70), // Widgets Text in weiß schattiert
            labelSmall: TextStyle(color: Colors.white), // Widgets Text in weiß
          ),
          inputDecorationTheme: InputDecorationTheme(
            labelStyle:
                TextStyle(color: Colors.white), // Eingabefeld Label in weiß
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
          iconTheme: IconThemeData(
            color: Colors.white, // Icons in weiß
          ),
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.green[900],
            titleTextStyle: TextStyle(color: Colors.white, fontSize: 20),
            iconTheme: IconThemeData(color: Colors.white),
          ),
          buttonTheme: ButtonThemeData(
            buttonColor: Colors.white, // Hintergrundfarbe der Buttons
            textTheme: ButtonTextTheme.primary,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              foregroundColor: Colors.green[900],
              backgroundColor: Colors.white, // Textfarbe
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
          ),
        ),
        home: HomePage(),
      ),
    );
  }
}
