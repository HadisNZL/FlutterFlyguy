import 'package:go_router/go_router.dart';

import '../../pages/auth/login_page.dart';
import '../../pages/main/main_page.dart';
import '../../pages/splash/splash_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (context, state) => const SplashPage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/main', builder: (context, state) => const MainPage()),
  ],
);
