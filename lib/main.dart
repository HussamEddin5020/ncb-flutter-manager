import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:manager_web/screens/login_screen.dart';
import 'package:manager_web/screens/dashboard_screen.dart';
import 'package:manager_web/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget _initialScreen = const LoginScreen();
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await ApiService.getToken();
      final employeeData = await ApiService.getEmployeeData();
      
      if (token != null && employeeData != null) {
        // Check if user is manager
        if (employeeData['role'] == 'manager') {
          setState(() {
            _initialScreen = const DashboardScreen();
            _isCheckingAuth = false;
          });
          return;
        }
      }
    } catch (e) {
      // If any error, show login screen
    }
    
    setState(() {
      _initialScreen = const LoginScreen();
      _isCheckingAuth = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مدير - منصة الاستلامات الموحدة',
      debugShowCheckedModeBanner: false,

      // Arabic localization
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // RTL support
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 238, 239, 237),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF2F2F7),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.zero,
        ),
        listTileTheme: const ListTileThemeData(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        dividerColor: Colors.transparent,
        fontFamily: 'Tajawal',
      ),

      home: _isCheckingAuth 
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _initialScreen,
    );
  }
}
