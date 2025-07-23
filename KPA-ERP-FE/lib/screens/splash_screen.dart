import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:kpa_erp/models/auth_model.dart';
import 'package:kpa_erp/routes.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _loadAndNavigate();
  }

  Future<void> _loadAndNavigate() async {
    // We add a small delay to ensure the build is complete before navigating.
    await Future.delayed(const Duration(milliseconds: 50));

    if (!mounted) return;

    final authModel = Provider.of<AuthModel>(context, listen: false);
    await authModel.loadAuthState();
    
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastRoute = prefs.getString('lastRoute');
    
    if (!mounted) return;

    if (kIsWeb) {
      if (authModel.isAuthenticated && lastRoute != null && lastRoute != '/') {
        Navigator.pushReplacementNamed(context, lastRoute);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    } else {
      if (authModel.isAuthenticated) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //
    // --- THE FIX IS HERE ---
    // The Image widget has been removed. The screen will now only show
    // the circular progress indicator.
    //
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image widget was here, but is now removed.
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
