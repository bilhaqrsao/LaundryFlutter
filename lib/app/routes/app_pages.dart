import 'package:get/get.dart';

import '../modules/bottombar/bindings/bottombar_binding.dart';
import '../modules/bottombar/views/bottombar_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/information/bindings/information_binding.dart';
import '../modules/information/views/information_views.dart';
import '../modules/konsumen/bindings/konsumen_binding.dart';
import '../modules/konsumen/views/konsumen_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/service/bindings/service_binding.dart';
import '../modules/service/views/service_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/trasanction/bindings/trasanction_binding.dart';
import '../modules/trasanction/views/trasanction_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.TRASANCTION,
      page: () => TrasanctionView(),
      binding: TrasanctionBinding(),
    ),
    GetPage(
      name: _Paths.SERVICE,
      page: () => ServiceView(),
      binding: ServiceBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: _Paths.BOTTOMBAR,
      page: () => const BottomNavbar(),
      binding: BottombarBinding(),
    ),
    GetPage(
      name: _Paths.INFORMATION,
      page: () => InformationViews(),
      binding: InformationBinding(),
    ),
    GetPage(
      name: _Paths.KONSUMEN,
      page: () => KonsumenView(),
      binding: KonsumenBinding(),
    ),
  ];
}
