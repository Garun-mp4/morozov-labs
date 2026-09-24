import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/history/history_screen.dart';
import '../ui/home/home_screen.dart';
import '../ui/levels/levels_screen.dart';
import '../ui/results/results_screen.dart';
import '../ui/settings/settings_screen.dart';
import '../ui/statistics/statistics_screen.dart';
import '../ui/training/training_screen.dart';
import '../ui/training_setup/training_setup_screen.dart';

class AppRouter {
  const AppRouter._();

  static GoRouter create() {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/training/setup',
          builder: (context, state) => const TrainingSetupScreen(),
        ),
        GoRoute(
          path: '/training/:sessionId',
          builder: (context, state) => TrainingScreen(
            sessionId: int.parse(state.pathParameters['sessionId']!),
          ),
        ),
        GoRoute(
          path: '/results/:sessionId',
          builder: (context, state) => ResultsScreen(
            sessionId: int.parse(state.pathParameters['sessionId']!),
          ),
        ),
        GoRoute(path: '/levels', builder: (context, state) => const LevelsScreen()),
        GoRoute(path: '/history', builder: (context, state) => const HistoryScreen()),
        GoRoute(
          path: '/history/:sessionId',
          builder: (context, state) => ResultsScreen(
            sessionId: int.parse(state.pathParameters['sessionId']!),
            fromHistory: true,
          ),
        ),
        GoRoute(
          path: '/statistics',
          builder: (context, state) => const StatisticsScreen(),
        ),
        GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.explore_off_outlined, size: 48),
                const SizedBox(height: 12),
                const Text('Экран не найден'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/'), child: const Text('На главную')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
