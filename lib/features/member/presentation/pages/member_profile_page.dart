import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../providers/members_provider.dart';
import '../../../../repositories/member_repository.dart';

class MemberProfilePage extends ConsumerWidget {
  const MemberProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(memberDashboardStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileCard(context, statsAsync),
                    const SizedBox(height: 24),
                    _buildStatsRow(context, statsAsync),
                    const SizedBox(height: 26),
                    _buildMembershipCard(context),
                    const SizedBox(height: 26),
                    _buildPrRecordsGrid(context),
                    const SizedBox(height: 26),
                    _buildRoleSwitchCard(context),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildMemberBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const NeumorphicContainer(
                  padding: EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(Icons.arrow_back_ios_new, color: AppColors.primary, size: 18),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Athlete Profile',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Iron Forge Member #IF-1042',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const NeumorphicContainer(
            padding: EdgeInsets.all(8),
            borderRadius: 12,
            child: Icon(Icons.settings_outlined, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context, AsyncValue<MemberDashboardData> statsAsync) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerHighest,
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.network(
              'https://lh3.googleusercontent.com/aida-public/AB6AXuCCO3m4vbKxcQlPsPGxMF6cc-5OTfVPWq4WQmvwPEOeB0jS5d8WSbplaPKKImNe6FT9qADhpPeUvVwu-vRd4lEmq-IcyiRoOR0156ruYkU-6ybNUoSqf-G0yvyucQWgkpTduchOYdjm50j58aYc-pkh9szuvQZxtDPtfa-TaASHvrqVU3_NFmq7hTS7RYyrRL8f4WNnSBpMJDAFWiOHa3rkGNK8f0BVHwbwXe7Tz8iyrP2OvlqIEdKP',
              fit: BoxFit.cover,
              cacheWidth: 150,
              cacheHeight: 150,
              errorBuilder: (c, e, s) => const Icon(Icons.person, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Arjun Verma',
                      style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'PLATINUM',
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                const Text('Powerlifter • 83kg Class • Hauz Khas', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
                const SizedBox(height: 4),
                const Text('Coach: Vikram Rathore', style: TextStyle(color: AppColors.outline, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, AsyncValue<MemberDashboardData> statsAsync) {
    return statsAsync.maybeWhen(
      data: (data) => NeumorphicContainer(
        padding: const EdgeInsets.all(16),
        borderRadius: 18,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('STREAK', '${data.currentStreak}d 🔥', const Color(0xFFFF7043)),
            Container(width: 1, height: 32, color: AppColors.outlineVariant),
            _buildStatItem('WORKOUTS', '${data.workoutsThisMonth}', AppColors.onSurface),
            Container(width: 1, height: 32, color: AppColors.outlineVariant),
            _buildStatItem('XP', '${data.xp}', AppColors.primary),
            Container(width: 1, height: 32, color: AppColors.outlineVariant),
            _buildStatItem('BIG 3', '${data.bigThreeTotalKg.toInt()} kg', AppColors.secondary),
          ],
        ),
      ),
      orElse: () => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 15)),
        Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildMembershipCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ACTIVE MEMBERSHIP', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w800)),
              Text('ACTIVE', style: TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Elite Annual Pass (24/7 Access)', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 15)),
          const SizedBox(height: 2),
          const Text('Valid until 14 March 2027 • Free Sauna & Recovery', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildPrRecordsGrid(BuildContext context) {
    final prs = [
      {'lift': 'Deadlift', 'weight': '290 kg', 'rank': 'Gym #1'},
      {'lift': 'Squat', 'weight': '225 kg', 'rank': 'Gym #2'},
      {'lift': 'Bench Press', 'weight': '140 kg', 'rank': 'Gym #3'},
      {'lift': 'Strict OHP', 'weight': '92.5 kg', 'rank': 'Gym #2'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('OFFICIAL PERSONAL RECORDS', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.6,
          children: prs.map((pr) {
            return NeumorphicContainer(
              padding: const EdgeInsets.all(12),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(pr['lift']!, style: const TextStyle(color: AppColors.outline, fontSize: 10)),
                      Text(pr['rank']!, style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 9)),
                    ],
                  ),
                  Text(pr['weight']!, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRoleSwitchCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('APP INTERFACE MODE', style: TextStyle(color: AppColors.outline, fontSize: 10, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          const Text('Switch between Member View and Gym Owner / PT View seamlessly.', style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12)),
          const SizedBox(height: 14),
          ClayButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
            },
            height: 44,
            borderRadius: 12,
            color: AppColors.primary,
            child: const Text('Switch to Owner & Trainer Interface', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest.withValues(alpha: 0.95),
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
            _buildNavItem(context, icon: Icons.home_outlined, label: 'Home', route: AppRoutes.memberHome),
            _buildNavItem(context, icon: Icons.emoji_events_outlined, label: 'Compete', route: AppRoutes.compete),
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Arena Ranks', route: AppRoutes.localGymLeaderboard),
            _buildNavItem(context, icon: Icons.person, label: 'Profile', isActive: true, route: AppRoutes.memberProfile),
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
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
