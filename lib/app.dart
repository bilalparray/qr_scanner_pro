import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'providers/code_provider.dart';
import 'providers/ad_provider.dart';

import 'screens/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CodeProvider()),
        ChangeNotifierProvider(create: (_) => AdProvider()),
      ],
      child: MaterialApp(
        title: dotenv.env['APP_NAME'] ?? 'QR Scanner & Generator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          fontFamily: 'Poppins',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          fontFamily: 'Poppins',
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
