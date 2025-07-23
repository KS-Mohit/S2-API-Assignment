import 'package:kpa_erp/screens/Home_screen/check_sheet_form.dart';
import 'package:kpa_erp/screens/Home_screen/home_screen.dart';
import 'package:kpa_erp/screens/Home_screen/icf_wheel.dart';
import 'package:kpa_erp/screens/Home_screen/submitted_forms_screen.dart';
// FIX: Import the screen files, not the form files.
import 'package:kpa_erp/user_screen/login_screen.dart';
import 'package:kpa_erp/user_screen/sign_up_screen.dart';
// Import other screens as needed
import 'package:kpa_erp/screens/splash_screen.dart';
import 'package:kpa_erp/user_screen/forgot_password_screen.dart';
import 'package:kpa_erp/user_screen/login_mobile_screen.dart';
import 'package:kpa_erp/user_screen/mobile_otp_screen.dart';


class Routes {
  // Your existing route names
  static const String splashScreen = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String signUp = '/signup';
  static const String mobileLogin = '/mobile-login';
  static const String forgotPassword = '/forgot-password';
  static const String otpEnter = '/otp-enter';
  static const String wheelSpecForm = '/wheel-specification-form';
  static const String bogieChecksheetForm = '/bogie-checksheet-form';
  static const String submittedForms = '/submitted-forms'; 

  // The map that connects route names to screen widgets
  static final routes = {
    // FIX: Pointing to the correct screen widgets.
    splashScreen: (context) => const SplashScreen(), 
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    signUp: (context) => const SignUpScreen(),
    mobileLogin: (context) => const LoginMobileScreen(),
    forgotPassword: (context) => const ForgotPasswordScreen(),
    otpEnter: (context) => const MobileOtpScreen(),
    wheelSpecForm: (context) => const IcfWheelScreen(),
    bogieChecksheetForm: (context) => const ChecksheetFormScreen(),
    submittedForms: (context) => const SubmittedFormsScreen(),
  };
}
