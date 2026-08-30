import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/workout_session_model.dart';
import '../../../../providers/gym_dashboard_provider.dart';
import '../../../../repositories/gym_repository.dart';

class OwnerDashboardPage extends ConsumerWidget {
  const OwnerDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(gymDashboardStatsProvider);
    final trainingNowAsync = ref.watch(trainingNowStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeSection(context),
                    const SizedBox(height: 28),
                    _buildBentoGrid(context, statsAsync),
                    const SizedBox(height: 32),
                    _buildTrainingRightNow(context, trainingNowAsync),
                    const SizedBox(height: 32),
                    _buildNeedsAttention(context, statsAsync),
                    const SizedBox(height: 80), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.lightShadow,
            offset: Offset(-4, -4),
            blurRadius: 10,
          ),
          BoxShadow(
            color: AppColors.darkShadow,
            offset: Offset(4, 4),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceContainerHigh,
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCYbtPGXiEBX4T5zIDKQAdI_lgNRqH86r8BBUzXGhK1zMaiP2yqC1rlGxeQ4T7HpxidJdYjsJvyQRzc6L2PHCU0PnXwVbV3q4Nnt1p9LvknNJzK_9EXO-CeCrPlQdDGg3Xk-2aPBjBfTE-j8sUKQlTKZ6a58m9RC9RS4h7YXlkeFehaHE7zMw8O6OUA7zpAzhKCGUygP3Ai10XVZds3XT2JCpLG4ddgtCVjl69wW0rSzak9WM7JlHUK',
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'IronPulse Elite',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Owner • Iron Forge Fitness',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.memberHome);
                },
                child: NeumorphicContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  borderRadius: 12,
                  child: const Row(
                    children: [
                      Icon(Icons.swap_horiz, color: AppColors.primary, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'Member App',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const NeumorphicContainer(
                padding: EdgeInsets.all(8),
                borderRadius: 20,
                child: Icon(Icons.notifications_outlined, color: AppColors.primary, size: 22),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good Evening, Rahul',
          style: Theme.of(context).textTheme.displayMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "Here's your live gym pulse today.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ],
    );
  }

  Widget _buildBentoGrid(BuildContext context, AsyncValue<GymDashboardData> statsAsync) {
    return statsAsync.when(
      loading: () => GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: List.generate(
          4,
          (i) => const NeumorphicContainer(
            padding: EdgeInsets.all(16),
            child: ShimmerSkeleton(width: double.infinity, height: double.infinity),
          ),
        ),
      ),
      error: (e, st) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text('Live data sync: $e', style: const TextStyle(color: AppColors.outline)),
      ),
      data: (data) {
        final revenueInLakhs = (data.collectedRevenue / 100000).toStringAsFixed(2);

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildStatCard(
              context,
              icon: Icons.groups_outlined,
              value: '${data.activeMembers}',
              label: 'ACTIVE MEMBERS',
              badgeText: '+12 this wk',
              badgeColor: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.membersDirectory),
            ),
            _buildStatCard(
              context,
              icon: Icons.fitness_center_outlined,
              value: '${data.workoutsToday}',
              label: 'TRAINED TODAY',
              onTap: () => Navigator.pushNamed(context, AppRoutes.gymAnalytics),
            ),
            _buildStatCard(
              context,
              icon: Icons.event_available_outlined,
              value: '${data.consistencyPercentage.toStringAsFixed(0)}%',
              label: 'CONSISTENCY',
              valueColor: AppColors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.gymAnalytics),
            ),
            _buildStatCard(
              context,
              icon: Icons.payments_outlined,
              value: '₹${revenueInLakhs}L',
              label: 'COLLECTED FEES',
              badgeText: '${data.overdueCount} Overdue',
              badgeColor: data.overdueCount > 0 ? AppColors.error : AppColors.primary,
              onTap: () => Navigator.pushNamed(context, AppRoutes.paymentsMemberships),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    String? badgeText,
    Color? badgeColor,
    Color? valueColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: AppColors.outline),
                if (badgeText != null && badgeColor != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: badgeColor),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: valueColor ?? AppColors.onBackground),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingRightNow(BuildContext context, AsyncValue<List<WorkoutSessionModel>> sessionsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00E676),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x6600E676),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'TRAINING RIGHT NOW',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
            sessionsAsync.maybeWhen(
              data: (list) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${list.length} Athletes Active',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),
          ],
        ),
        const SizedBox(height: 16),
        sessionsAsync.when(
          loading: () => const NeumorphicContainer(
            padding: EdgeInsets.all(16),
            child: ShimmerSkeleton(width: double.infinity, height: 70),
          ),
          error: (e, st) => const Text('Live stream syncing...', style: TextStyle(color: AppColors.outline)),
          data: (sessions) {
            if (sessions.isEmpty) {
              return const NeumorphicContainer(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'No athletes currently working out on floor.',
                    style: TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sessions.length,
              itemBuilder: (context, index) {
                final session = sessions[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildTrainingUserCard(
                    context,
                    name: session.athleteName ?? 'Athlete',
                    program: session.workoutName,
                    progress: session.progressPercentage.toInt(),
                    imageUrl: session.athleteAvatar,
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTrainingUserCard(BuildContext context, {required String name, required String program, required int progress, String? imageUrl}) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: imageUrl != null
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            cacheWidth: 100,
                            cacheHeight: 100,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.person),
                          )
                        : Center(child: Text(name.isNotEmpty ? name[0] : 'A', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.onSurfaceVariant))),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleSmall),
                      Text(program, style: Theme.of(context).textTheme.labelMedium),
                    ],
                  ),
                ],
              ),
              Text('$progress%', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 8,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(4),
            ),
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: (progress / 100.0).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNeedsAttention(BuildContext context, AsyncValue<GymDashboardData> statsAsync) {
    return statsAsync.maybeWhen(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEEDS ATTENTION',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.error,
                  letterSpacing: 1.2,
                ),
          ),
          const SizedBox(height: 16),
          NeumorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.expiringIn7Days}', style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.error)),
                        Text('Expiring Memberships', style: Theme.of(context).textTheme.bodyMedium),
                        Text('In the next 7 days', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.timer_outlined, color: AppColors.error),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.membersDirectory),
                  child: const NeumorphicContainer(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: Text('View Expiring Roster', style: TextStyle(fontWeight: FontWeight.w700))),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          NeumorphicContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data.overdueCount}', style: Theme.of(context).textTheme.displayMedium),
                        Text('Overdue Invoices', style: Theme.of(context).textTheme.bodyMedium),
                        Text('₹${data.overdueAmount.toInt()} action required', style: Theme.of(context).textTheme.labelMedium),
                      ],
                    ),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.money_off_outlined, color: AppColors.errorContainer),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClayButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Dispatched WhatsApp auto-reminders for ${data.overdueCount} overdue members.'),
                        backgroundColor: AppColors.surfaceContainerHigh,
                      ),
                    );
                  },
                  height: 48,
                  color: AppColors.errorContainer,
                  child: Text(
                    'Send ${data.overdueCount} Reminders',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onErrorContainer,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            offset: Offset(0, -4),
            blurRadius: 10,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, icon: Icons.dashboard, label: 'Dash', isActive: true, route: AppRoutes.ownerDashboard),
            _buildNavItem(context, icon: Icons.group_outlined, label: 'Members', route: AppRoutes.membersDirectory),
            _buildNavItem(context, icon: Icons.fitness_center_outlined, label: 'Train', route: AppRoutes.personalTraining),
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Ranks', route: AppRoutes.gymRankings),
            _buildNavItem(context, icon: Icons.payments_outlined, label: 'Pay', route: AppRoutes.paymentsMemberships),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, {required IconData icon, required String label, bool isActive = false, required String route}) {
    return GestureDetector(
      onTap: () {
        if (!isActive) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x4D000000),
                    offset: Offset(0, 4),
                    blurRadius: 8,
                  ),
                ],
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? AppColors.onPrimary : AppColors.outline),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: isActive ? AppColors.onPrimary : AppColors.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
