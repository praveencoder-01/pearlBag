// import 'package:flutter/material.dart';
// import 'package:food_website/screens/home_screen.dart';
// import 'package:food_website/auth/auth_service.dart';

// class AuthLayout extends StatelessWidget {
//   const AuthLayout ({
//     super.key,
//     this.pageIfNotConnected,
//   });

//   final Widget? pageIfNotConnected;

//   @override 
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder(
//       valueListenable: authService,
//       builder: (context, authService, child,){
//        return StreamBuilder(stream: authService.authStateChanges, builder: (context, snapshot) {
//          Widget widget;
//          if(snapshot.connectionState == ConnectionState.waiting) {
//           widget = CircularProgressIndicator();
//         }else if(snapshot.hasData) {
//           widget = HomeScreen();
//         } else {
//           widget = pageIfNotConnected ?? const WelcomePage();
//         }
//         return widget;
//        });
//       }
//     );
//   }


// }