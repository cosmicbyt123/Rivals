import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/ranking_models.dart';
import '../../../../providers/rankings_provider.dart';

class GymRankingsPage extends ConsumerStatefulWidget {
  const GymRankingsPage({super.key});

  @override
  ConsumerState<GymRankingsPage> createState() => _GymRankingsPageState();
}

class _GymRankingsPageState extends ConsumerState<GymRankingsPage> {
  int _selectedScopeIndex = 0; // 0: City League, 1: State Division, 2: National Elite, 3: Direct Rivals
  int _selectedCategoryIndex = 0; // 0: Total Power, 1: Consistency, 2: Heavy Lifters

  final List<String> _scopes = ['City League', 'State Div', 'National', 'Rivals'];
  final List<String> _categories = ['Overall Power', 'Consistency', 'Total Volume'];

  @override
  Widget build(BuildContext context) {
    final currentScope = _scopes[_selectedScopeIndex];
    final rankingsAsync = ref.watch(gymRankingsProvider(currentScope));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: rankingsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: ShimmerSkeleton(width: double.infinity, height: 300),
                ),
                error: (e, st) => Center(
                  child: Text('Error loading standings: $e', style: const TextStyle(color: AppColors.outline)),
                ),
                data: (gymList) {
                  final ourGym = gymList.firstWhere(
                    (g) => g.isOurGym,
                    orElse: () => gymList.isNotEmpty ? gymList.first : GymRankingItem(
                      rank: 3,
                      name: 'Iron Forge Fitness',
                      location: 'Hauz Khas, Delhi',
                      score: '48,920',
                      change: 2,
                      members: 248,
                      consistency: '87%',
                      isOurGym: true,
                      avatarText: 'IF',
                    ),
                  );

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildScopeSelector(),
                        const SizedBox(height: 20),
                        _buildCurrentGymStatusCard(context, ourGym),
                        const SizedBox(height: 26),
                        _buildActiveRivalryWarCard(context),
                        const SizedBox(height: 28),
                        _buildPodiumShowcase(context, gymList),
                        const SizedBox(height: 28),
                        _buildCategoryPills(),
                        const SizedBox(height: 20),
                        _buildLeaderboardSection(context, gymList),
                        const SizedBox(height: 28),
                        _buildSeasonRewardsCard(context),
                        const SizedBox(height: 36),
                      ],
                    ),
                  );
                },
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
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  } else {
                    Navigator.pushReplacementNamed(context, AppRoutes.ownerDashboard);
                  }
                },
                child: const NeumorphicContainer(
                  padding: EdgeInsets.all(8),
                  borderRadius: 12,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Gym Rankings',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Delhi NCR • Live Season Standings',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          NeumorphicContainer(
            padding: const EdgeInsets.all(8),
            borderRadius: 12,
            child: const Icon(
              Icons.emoji_events_outlined,
              color: AppColors.primary,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScopeSelector() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: 16,
      child: Row(
        children: List.generate(_scopes.length, (index) {
          final isSelected = _selectedScopeIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedScopeIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            offset: const Offset(0, 4),
                            blurRadius: 10,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _scopes[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentGymStatusCard(BuildContext context, GymRankingItem ourGym) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 22,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primary, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        '#${ourGym.rank}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            ourGym.name,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.verified, color: AppColors.primary, size: 16),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(Icons.arrow_upward, color: Color(0xFF66BB6A), size: 14),
                          const SizedBox(width: 2),
                          Text(
                            '+${ourGym.change} Ranks this week',
                            style: const TextStyle(
                              color: Color(0xFF66BB6A),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${ourGym.members} Athletes',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      ourGym.score,
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                    const Text(
                      'PTS',
                      style: TextStyle(
                        color: AppColors.outline,
                        fontWeight: FontWeight.w700,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.military_tech_rounded, color: AppColors.secondary, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Target: #2 Olympus Barbell',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Text(
                  '1,450 pts needed',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRivalryWarCard(BuildContext context) {
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
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ACTIVE GYM WAR (WEEK 4)',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppColors.error,
                        letterSpacing: 1.2,
                      ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Ends in 2d 14h',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            children: [
              const Text(
                'HEAVY SQUAT TONNAGE CLASH',
                style: TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'IRON FORGE',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '14.8 Tons',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.onSurface,
                              ),
                        ),
                        const Text('92 lifters logged', style: TextStyle(color: AppColors.outline, fontSize: 10)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.outlineVariant),
                    ),
                    child: const Text(
                      'VS',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'TITAN STRENGTH',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '15.2 Tons',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w900,
                                color: AppColors.onSurface,
                              ),
                        ),
                        const Text('104 lifters logged', style: TextStyle(color: AppColors.outline, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const SizedBox(
                  height: 10,
                  child: Row(
                    children: [
                      Expanded(flex: 49, child: ColoredBox(color: AppColors.primary)),
                      SizedBox(width: 2),
                      Expanded(flex: 51, child: ColoredBox(color: AppColors.surfaceBright)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ClayButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Rally notification sent to active lifters! +350kg bonus activated.'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 44,
                borderRadius: 12,
                color: AppColors.primary,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, color: AppColors.onPrimary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'Rally Members for Squat Day (+400kg)',
                      style: TextStyle(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumShowcase(BuildContext context, List<GymRankingItem> gymList) {
    if (gymList.length < 3) return const SizedBox.shrink();

    final first = gymList.firstWhere((g) => g.rank == 1, orElse: () => gymList[0]);
    final second = gymList.firstWhere((g) => g.rank == 2, orElse: () => gymList[1]);
    final third = gymList.firstWhere((g) => g.rank == 3, orElse: () => gymList[2]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TOP 3 PODIUM',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
          borderRadius: 22,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPodiumColumn(
                context,
                rank: 2,
                name: second.name.split(' ')[0],
                score: '${(int.tryParse(second.score.replaceAll(',', '')) ?? 50000) ~/ 1000}K',
                badgeColor: const Color(0xFFC0C0C0),
                podiumHeight: 70,
                avatarText: second.avatarText,
                isOurGym: second.isOurGym,
              ),
              _buildPodiumColumn(
                context,
                rank: 1,
                name: first.name.split(' ')[0],
                score: '${(int.tryParse(first.score.replaceAll(',', '')) ?? 54000) ~/ 1000}K',
                badgeColor: AppColors.primary,
                podiumHeight: 100,
                isFirst: true,
                avatarText: first.avatarText,
                isOurGym: first.isOurGym,
              ),
              _buildPodiumColumn(
                context,
                rank: 3,
                name: third.name.split(' ')[0],
                score: '${(int.tryParse(third.score.replaceAll(',', '')) ?? 48000) ~/ 1000}K',
                badgeColor: const Color(0xFFCD7F32),
                podiumHeight: 55,
                avatarText: third.avatarText,
                isOurGym: third.isOurGym,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumColumn(
    BuildContext context, {
    required int rank,
    required String name,
    required String score,
    required Color badgeColor,
    required double podiumHeight,
    bool isFirst = false,
    bool isOurGym = false,
    required String avatarText,
  }) {
    return Column(
      children: [
        if (isFirst)
          const Icon(Icons.workspace_premium, color: AppColors.primary, size: 28)
        else
          const SizedBox(height: 28),
        const SizedBox(height: 4),
        Container(
          width: isFirst ? 50 : 42,
          height: isFirst ? 50 : 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isOurGym ? AppColors.primaryContainer : AppColors.surfaceContainerHighest,
            border: Border.all(color: badgeColor, width: 2),
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.4),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              avatarText,
              style: TextStyle(
                color: isOurGym ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: FontWeight.w800,
                fontSize: isFirst ? 16 : 13,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: TextStyle(
            color: isOurGym ? AppColors.primary : AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 75,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isOurGym
                  ? [AppColors.primary, AppColors.primaryContainer]
                  : [AppColors.surfaceBright, AppColors.surfaceContainerHighest],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: isOurGym ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryPills() {
    return Row(
      children: List.generate(_categories.length, (index) {
        final isSelected = _selectedCategoryIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategoryIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                ),
              ),
              child: Center(
                child: Text(
                  _categories[index],
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

  Widget _buildLeaderboardSection(BuildContext context, List<GymRankingItem> gymList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COMPLETE STANDINGS (${gymList.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Live Score Calculation',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: gymList.length,
          itemBuilder: (context, index) {
            final gym = gymList[index];
            final isOurGym = gym.isOurGym;
            final rank = gym.rank;
            final change = gym.change;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                child: Row(
                  children: [
                    SizedBox(
                      width: 38,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '#$rank',
                            style: TextStyle(
                              color: isOurGym ? AppColors.primary : AppColors.onSurface,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          if (change > 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_drop_up, color: Color(0xFF66BB6A), size: 14),
                                Text('$change', style: const TextStyle(color: Color(0xFF66BB6A), fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            )
                          else if (change < 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.arrow_drop_down, color: AppColors.error, size: 14),
                                Text('${change.abs()}', style: const TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            )
                          else
                            const Text('–', style: TextStyle(color: AppColors.outline, fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isOurGym ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: isOurGym ? Border.all(color: AppColors.primary) : null,
                      ),
                      child: Center(
                        child: Text(
                          gym.avatarText,
                          style: TextStyle(
                            color: isOurGym ? AppColors.primary : AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  gym.name,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: isOurGym ? AppColors.primary : AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              if (isOurGym) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'YOU',
                                    style: TextStyle(
                                      color: AppColors.onPrimary,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${gym.location} • ${gym.members} athletes',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${gym.score} pts',
                          style: TextStyle(
                            color: isOurGym ? AppColors.primary : AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${gym.consistency} consistency',
                          style: const TextStyle(
                            color: AppColors.outline,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSeasonRewardsCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.military_tech_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Text(
                'SEASON 4 REWARDS & PERKS',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Finishing in Top 3 qualifies Iron Forge for the National Invitational Cup & ₹1.5L Sponsor Equipment Grant.',
            style: TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ClayButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Challenge request sent to Olympus Barbell Club!'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            height: 46,
            borderRadius: 14,
            color: AppColors.surfaceContainerHigh,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                SizedBox(width: 8),
                Text(
                  'Issue 1v1 Gym Challenge',
                  style: TextStyle(
                    color: AppColors.onSurface,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
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
            _buildNavItem(context, icon: Icons.dashboard_outlined, label: 'Dash', route: AppRoutes.ownerDashboard),
            _buildNavItem(context, icon: Icons.group_outlined, label: 'Members', route: AppRoutes.membersDirectory),
            _buildNavItem(context, icon: Icons.fitness_center_outlined, label: 'Train', route: AppRoutes.personalTraining),
            _buildNavItem(context, icon: Icons.leaderboard, label: 'Ranks', isActive: true, route: AppRoutes.gymRankings),
            _buildNavItem(context, icon: Icons.payments_outlined, label: 'Pay', route: AppRoutes.paymentsMemberships),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    bool isActive = false,
    required String route,
  }) {
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
