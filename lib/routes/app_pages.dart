import 'package:get/get.dart';
import 'package:havadurumu/pages/register/views/otp_verification_page.dart';

import '../pages/forgotPassword/bindings/forgotPassword_binding.dart';
import '../pages/forgotPassword/views/forgotPassword_page.dart';
import '../pages/home/bindings/home_binding.dart';
import '../pages/home/views/home_page.dart';
import '../pages/login/bindings/login_binding.dart';
import '../pages/login/views/login_page.dart';
import '../pages/notifications/bindings/notifications_binding.dart';
import '../pages/notifications/views/notifications_page.dart';
import '../pages/onboarding/bindings/onboarding_binding.dart';
import '../pages/onboarding/views/onboarding_page.dart';
import '../pages/register/bindings/email_verification_binding.dart';
import '../pages/register/bindings/otp_verification_binding.dart';
import '../pages/register/bindings/register_binding.dart';
import '../pages/register/views/email_verification_page.dart';
import '../pages/register/views/register_page.dart';
import '../pages/search/bindings/search_binding.dart';
import '../pages/search/views/search_page.dart';
import 'app_routes.dart';

class AppPages {
  static const initial = Routes.ONBOARDING;

  static final routes = [
    GetPage(
      name: Routes.LOGIN,
      page: LoginView.new,
      binding: LoginBinding(),
    ),
    GetPage(
      name: Routes.HOME,
      page: HomeView.new,
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.SEARCH,
      page: SearchView.new,
      binding: SearchBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: RegisterView.new,
      binding: RegisterBinding(),
    ),
    GetPage(
      name: Routes.ONBOARDING,
      page: OnboardingView.new,
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: Routes.FORGOTPASSWORD,
      page: ForgotPasswordView.new,
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: Routes.EMAILVERIFICATION,
      page: EmailVerificationView.new,
      binding: EmailVerificationBinding(),
    ),
    GetPage(
      name: Routes.OTPVERIFICATION,
      page: OTPVerificationView.new,
      binding: OTPVerificationBinding(),
    ),
    GetPage(
      name: Routes.NOTIFICATIONS,
      page: NotificationsView.new,
      binding: NotificationsBinding(),
    ),
  ];
}
