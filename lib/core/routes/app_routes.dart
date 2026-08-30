import 'package:flutter/material.dart';
import '../../features/business/presentation/pages/members_directory_page.dart';
import '../../features/business/presentation/pages/personal_training_page.dart';
import '../../features/business/presentation/pages/owner_dashboard_page.dart';
import '../../features/business/presentation/pages/gym_rankings_page.dart';
import '../../features/business/presentation/pages/payments_memberships_page.dart';
import '../../features/business/presentation/pages/gym_analytics_page.dart';
import '../../features/business/presentation/pages/local_gym_leaderboard_page.dart';
import '../../features/member/presentation/pages/member_home_page.dart';
import '../../features/member/presentation/pages/active_workout_page.dart';
import '../../features/member/presentation/pages/compete_page.dart';
import '../../features/member/presentation/pages/member_profile_page.dart';

class AppRoutes {
  static const String initial = '/';
  
  // Gym Owner & Trainer Routes
  static const String ownerDashboard = '/owner-dashboard';
  static const String membersDirectory = '/members-directory';
  static const String personalTraining = '/personal-training';
  static const String gymRankings = '/gym-rankings';
  static const String paymentsMemberships = '/payments-memberships';
  static const String gymAnalytics = '/gym-analytics';
  static const String localGymLeaderboard = '/local-gym-leaderboard';

  // Member & Athlete Routes
  static const String memberHome = '/member-home';
  static const String activeWorkout = '/active-workout';
  static const String compete = '/compete';
  static const String memberProfile = '/member-profile';

  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const OwnerDashboardPage(),
        ownerDashboard: (context) => const OwnerDashboardPage(),
        membersDirectory: (context) => const MembersDirectoryPage(),
        personalTraining: (context) => const PersonalTrainingPage(),
        gymRankings: (context) => const GymRankingsPage(),
        paymentsMemberships: (context) => const PaymentsMembershipsPage(),
        gymAnalytics: (context) => const GymAnalyticsPage(),
        localGymLeaderboard: (context) => const LocalGymLeaderboardPage(),
        
        // Member Routes
        memberHome: (context) => const MemberHomePage(),
        activeWorkout: (context) => const ActiveWorkoutPage(),
        compete: (context) => const CompetePage(),
        memberProfile: (context) => const MemberProfilePage(),
      };
}
