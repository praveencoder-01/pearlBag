import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:food_website/auth_wrapper.dart';
import 'package:food_website/core/theme.dart';
import 'package:food_website/providers/cart_provider.dart';
import 'package:food_website/providers/drawer_provider.dart';
// import 'package:food_website/providers/product_provider.dart';
import 'package:provider/provider.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'providers/auth_provider.dart';
import 'providers/category_provider.dart';
// import 'screens/home_screen.dart';

void main() async {
  Animate.restartOnHotReload = true;
   VisibilityDetectorController.instance.updateInterval = Duration.zero;
   WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => CategoryProvider()),
    ChangeNotifierProvider(create: (_) => DrawerProvider()),
    // ChangeNotifierProvider(create: (_) => ProductProvider()),
  ],
  child: MaterialApp(
    
    debugShowCheckedModeBanner: false,
    theme: appTheme,

    home: const AuthWrapper(),
  ),
);
  }
}
