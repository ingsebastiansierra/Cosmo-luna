import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Configurar Firebase antes de descomentar
  // await Firebase.initializeApp();
  // await MobileAds.instance.initialize();
  runApp(const NebulaCodeApp());
}

class NebulaCodeApp extends StatelessWidget {
  const NebulaCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula Code',
      theme: ThemeData(
        colorScheme: ColorScheme.dark(primary: Color(0xFF00B4D8)),
        fontFamily: 'SpaceGrotesk',
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
