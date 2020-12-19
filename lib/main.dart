import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/services.dart';

import './pages/login_page.dart';
import './pages/registration_page.dart';
import './services/navigation_service.dart';
import './pages/home_page.dart';
import './providers/auth_provider.dart';


void main() async {

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.black , // status bar color
  ));

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  bool _isLogged = await AuthProvider().checkIfUserIsLoggedForInitialRoute();
  String initialRouteString = _isLogged ? 'home' : 'login';
  runApp(WiberChatApp(route: initialRouteString));
}

class WiberChatApp extends StatelessWidget {
  // This widget is the root of your application.

  final String route;

  WiberChatApp({this.route});

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black, // navigation bar color
    ));

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wiber Chat',
      navigatorKey: NavigationService.instance.navigatorKey,
      theme: ThemeData(
        fontFamily: 'VarelaRound',
        brightness: Brightness.dark,
        primaryColor: Colors.black,
        accentColor: Color.fromRGBO(7, 116, 255, 1),
        backgroundColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: route,
      routes: {
        'login': (BuildContext _context) => LoginPage(),
        'register': (BuildContext _context) => RegistrationPage(),
        'home': (BuildContext _context) => HomePage(),
      },
    );
  }
}
