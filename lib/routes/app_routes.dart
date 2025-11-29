import 'package:flutter/material.dart';

import '../presentation/calendar_view/calendar_view.dart';
import '../presentation/create_game/create_game.dart';
import '../presentation/game_detail/game_detail.dart';
import '../presentation/group_detail/group_detail.dart';
import '../presentation/groups_dashboard/groups_dashboard.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/payment_tracker/payment_tracker.dart';
import '../presentation/player_stats/player_stats.dart';
import '../presentation/profile/profile_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String paymentTracker = '/payment-tracker';
  static const String playerStats = '/player-stats';
  static const String splash = '/splash-screen';
  static const String login = '/login-screen';
  static const String groupsDashboard = '/groups-dashboard';
  static const String groupDetail = '/group-detail';
  static const String calendarView = '/calendar-view';
  static const String createGame = '/create-game';
  static const String gameDetail = '/game-detail';
  static const String profileScreen = '/profile-screen';

  static Map<String, WidgetBuilder> get routes => {
    initial: (context) => const SplashScreen(),
    paymentTracker: (context) => const PaymentTracker(),
    playerStats: (context) => const PlayerStats(),
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    groupsDashboard: (context) => const GroupsDashboard(),
    groupDetail: (context) => const GroupDetail(),
    calendarView: (context) => const CalendarView(),
    createGame: (context) => const CreateGame(),
    gameDetail: (context) => const GameDetail(),
    profileScreen: (context) => const ProfileScreen(),
    // TODO: Add your other routes here
  };
}
