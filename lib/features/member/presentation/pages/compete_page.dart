import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';

class CompetePage extends ConsumerStatefulWidget {
  const CompetePage({super.key});

  @override
  ConsumerState<CompetePage> createState() => _CompetePageState();
}

class _CompetePageState extends ConsumerState<CompetePage> {
  int _selectedTab = 0; // 0: 1v1 Duels, 1: Gym Wars, 2: Monthly Challenges

  final List<Map<String, dynamic>> _duels = [
    {
      'rival': 'Rahul Sen',
      'avatar': 'RS',
      'challenge': 'Max Bench Press Reps @ 100kg',
      'myScore': '14 Reps',
      'rivalScore': '12 Reps',
      'timeLeft': '6 hours left',
      'xp': '+150 XP',
      'status': 'winning',
    },
    {
      'rival': 'Devansh Chawla',
      'avatar': 'DC',
      'challenge': 'Squat Tonnage (3 Workouts)',
      'myScore': '8.4 Tons',
      'rivalScore': '9.1 Tons',
      'timeLeft': '1 day left',
      'xp': '+200 XP',
      'status': 'trailing',
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                    _buildPvpRecordBanner(context),
                    const SizedBox(height: 20),
                    _buildTabs(),
                    const SizedBox(height: 20),
                    _buildDuelsList(context),
                    const SizedBox(height: 24),
                    _buildCreateChallengeCard(context),
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
                    'Arena Battles & Duels',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    '1v1 Challenges & XP Stakes',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          const NeumorphicContainer(
            padding: EdgeInsets.all(8),
            borderRadius: 12,
            child: Icon(Icons.flash_on, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildPvpRecordBanner(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('WINS', '18', const Color(0xFF00E676)),
          Container(width: 1, height: 32, color: AppColors.outlineVariant),
          _buildStat('LOSSES', '4', AppColors.error),
          Container(width: 1, height: 32, color: AppColors.outlineVariant),
          _buildStat('WIN RATE', '82%', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, Color color) {
    return Column(
      children: [
        Text(val, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 18)),
        Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 9, fontWeight: FontWeight.w700)),
      ],
    );
  }

  Widget _buildTabs() {
    final tabs = ['1v1 Duels (2)', 'Gym Wars', 'Quests'];

    return Row(
      children: List.generate(tabs.length, (index) {
        final isSelected = _selectedTab == index;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedTab = index),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.only(right: index < tabs.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                ),
              ),
              child: Center(
                child: Text(
                  tabs[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDuelsList(BuildContext context) {
    return Column(
      children: _duels.map((duel) {
        final isWinning = duel['status'] == 'winning';
        final statusColor = isWinning ? const Color(0xFF00E676) : const Color(0xFFFF7043);

        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(16),
            borderRadius: 18,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerHighest,
                          ),
                          child: Center(
                            child: Text(
                              duel['avatar'] as String,
                              style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'vs ${duel['rival']}',
                              style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 13),
                            ),
                            Text(
                              duel['timeLeft'] as String,
                              style: const TextStyle(color: AppColors.outline, fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isWinning ? 'WINNING' : 'TRAILING',
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  duel['challenge'] as String,
                  style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('You: ${duel['myScore']}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 13)),
                    Text('${duel['rival']}: ${duel['rivalScore']}', style: const TextStyle(color: AppColors.outline, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCreateChallengeCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 18,
      child: Column(
        children: [
          const Text(
            'Challenge a Gym Mate',
            style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 6),
          const Text(
            'Stake 100 XP on Deadlift, Squat, or Consistency battle.',
            style: TextStyle(color: AppColors.outline, fontSize: 11),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          ClayButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Duel invitation sent! Waiting for athlete acceptance.'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            height: 44,
            borderRadius: 12,
            color: AppColors.primary,
            child: const Text('Send 1v1 Challenge', style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800)),
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
            _buildNavItem(context, icon: Icons.emoji_events, label: 'Compete', isActive: true, route: AppRoutes.compete),
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Arena Ranks', route: AppRoutes.localGymLeaderboard),
            _buildNavItem(context, icon: Icons.person_outline, label: 'Profile', route: AppRoutes.memberProfile),
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
