import 'package:firstone/pages/about_page.dart';
import 'package:firstone/pages/feedback_page.dart';
import 'package:firstone/pages/insights_page.dart';
import 'package:firstone/pages/obj_detection.dart';
import 'package:firstone/pages/settings_page.dart';
import 'package:firstone/pages/feedback_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:camera/camera.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'pages/home_page.dart';
import 'pages/splash_screen.dart';

// Global navigator key so we can navigate after splash
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize available cameras
  final cameras = await availableCameras();

  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({super.key, required this.cameras});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "NeuraLens",
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
        ),
        useMaterial3: true,
      ),

      routes: {
        '/about': (_) => const AboutScreen(),
        '/insights': (_) => const InsightsPage(),
        '/settings': (_) => const SettingsPage(),
        '/feedback': (_) => const FeedbackPage(),
        '/obj_detection': (_) => const ObjectDetectionPage(),
      },

      home: SplashScreen(
        onInitializationComplete: () {
          navigatorKey.currentState?.pushReplacement(
            MaterialPageRoute(builder: (_) => HomePage(cameras: cameras)),
          );
        },
      ),
    );
  }
}
