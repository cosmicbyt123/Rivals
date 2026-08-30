import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/ranking_models.dart';
import '../../../../providers/rankings_provider.dart';

class LocalGymLeaderboardPage extends ConsumerStatefulWidget {
  const LocalGymLeaderboardPage({super.key});

  @override
  ConsumerState<LocalGymLeaderboardPage> createState() => _LocalGymLeaderboardPageState();
}

class _LocalGymLeaderboardPageState extends ConsumerState<LocalGymLeaderboardPage> {
  int _selectedCategoryIndex = 0; // 0: Overall, 1: Big 3, 2: Deadlift, 3: Squat, 4: Bench, 5: Streak
  int _selectedDivisionIndex = 0; // 0: All, 1: Men's, 2: Women's
  String _searchQuery = '';
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          _searchQuery = val;
        });
      }
    });
  }


  final List<String> _categories = [
    'Overall Points',
    'Big 3 Total',
    'Deadlift',
    'Squat',
    'Bench Press',
    'Consistency 🔥',
  ];

  final List<String> _divisions = ['All Divisions', "Men's Open", "Women's Open", 'Masters 40+'];

  final List<Map<String, dynamic>> _gymRecords = [
    {'title': 'Max Deadlift', 'holder': 'Arjun Verma', 'val': '290 kg', 'date': 'Aug 2026'},
    {'title': 'Max Squat', 'holder': 'Rahul Sen', 'val': '245 kg', 'date': 'Jul 2026'},
    {'title': 'Max Bench', 'holder': 'Vikram Rathore', 'val': '165 kg', 'date': 'Aug 2026'},
    {'title': 'Longest Streak', 'holder': 'Kavita Nair', 'val': '112 Days', 'date': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    final athletesAsync = ref.watch(localAthleteLeaderboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: athletesAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: ShimmerSkeleton(width: double.infinity, height: 300),
                ),
                error: (e, st) => Center(
                  child: Text('Error loading leaderboard: $e', style: const TextStyle(color: AppColors.outline)),
                ),
                data: (athletes) {
                  final filteredAthletes = athletes.where((athlete) {
                    if (_searchQuery.isEmpty) return true;
                    final name = athlete.name.toLowerCase();
                    final division = athlete.division.toLowerCase();
                    final query = _searchQuery.toLowerCase();
                    return name.contains(query) || division.contains(query);
                  }).toList();

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 18),
                        _buildCategoryChips(),
                        const SizedBox(height: 14),
                        _buildDivisionSelector(),
                        const SizedBox(height: 24),
                        _buildGymHighlightsBanner(context, athletes.length),
                        const SizedBox(height: 26),
                        _buildPodiumShowcase(context, athletes),
                        const SizedBox(height: 28),
                        _buildLeaderboardSection(context, filteredAthletes),
                        const SizedBox(height: 28),
                        _buildGymRecordsWall(context),
                        const SizedBox(height: 28),
                        _buildLogPrActionCard(context),
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
                    'Local Leaderboard',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Iron Forge Arena • Live PR Standings',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.gymRankings);
            },
            child: NeumorphicContainer(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              borderRadius: 12,
              child: const Row(
                children: [
                  Icon(Icons.public, color: AppColors.primary, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'City War',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      borderRadius: 14,
      child: TextField(
        onChanged: _onSearchChanged,
        style: const TextStyle(color: AppColors.onSurface, fontSize: 13),
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: AppColors.outline, size: 20),
          border: InputBorder.none,
          hintText: 'Search athlete name or weight class...',
          hintStyle: const TextStyle(color: AppColors.outline, fontSize: 13),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.outline, size: 16),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_categories.length, (index) {
          final isSelected = _selectedCategoryIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.outlineVariant,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            offset: const Offset(0, 3),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildDivisionSelector() {
    return Row(
      children: List.generate(_divisions.length, (index) {
        final isSelected = _selectedDivisionIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedDivisionIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: EdgeInsets.only(right: index < _divisions.length - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                ),
              ),
              child: Center(
                child: Text(
                  _divisions[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 10,
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

  Widget _buildGymHighlightsBanner(BuildContext context, int lifterCount) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBannerStat(context, title: 'LIFTERS RANKED', value: '$lifterCount', icon: Icons.groups_outlined),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildBannerStat(context, title: 'TONNAGE (MO)', value: '142.8 T', icon: Icons.fitness_center_outlined),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildBannerStat(context, title: 'PRS BROKEN', value: '48', icon: Icons.bolt, valueColor: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildBannerStat(BuildContext context,
      {required String title, required String value, required IconData icon, Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, color: AppColors.outline, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 17,
                color: valueColor ?? AppColors.onSurface,
              ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.outline,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPodiumShowcase(BuildContext context, List<AthleteLeaderboardItem> athletes) {
    if (athletes.length < 3) return const SizedBox.shrink();

    final first = athletes[0];
    final second = athletes[1];
    final third = athletes[2];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ARENA TOP 3 CHAMPIONS',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 14),
        NeumorphicContainer(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
          borderRadius: 20,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPodiumColumn(
                context,
                rank: 2,
                name: second.name,
                stat: second.stat,
                badgeColor: const Color(0xFFC0C0C0),
                podiumHeight: 65,
                avatarText: second.avatarText,
                imageUrl: second.imageUrl,
              ),
              _buildPodiumColumn(
                context,
                rank: 1,
                name: first.name,
                stat: first.stat,
                badgeColor: AppColors.primary,
                podiumHeight: 95,
                isFirst: true,
                avatarText: first.avatarText,
                imageUrl: first.imageUrl,
              ),
              _buildPodiumColumn(
                context,
                rank: 3,
                name: third.name,
                stat: third.stat,
                badgeColor: const Color(0xFFCD7F32),
                podiumHeight: 50,
                avatarText: third.avatarText,
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
    required String stat,
    required Color badgeColor,
    required double podiumHeight,
    bool isFirst = false,
    required String avatarText,
    String? imageUrl,
  }) {
    return Column(
      children: [
        if (isFirst)
          const Icon(Icons.emoji_events, color: AppColors.primary, size: 26)
        else
          const SizedBox(height: 26),
        const SizedBox(height: 4),
        Container(
          width: isFirst ? 48 : 40,
          height: isFirst ? 48 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceContainerHighest,
            border: Border.all(color: badgeColor, width: 2),
            boxShadow: isFirst
                ? [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.35),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          clipBehavior: Clip.antiAlias,
          child: imageUrl != null
              ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 100,
                  cacheHeight: 100,
                  errorBuilder: (c, e, s) => Center(child: Text(avatarText)),
                )
              : Center(
                  child: Text(
                    avatarText,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                      fontSize: isFirst ? 15 : 12,
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 6),
        Text(
          name.split(' ')[0],
          style: TextStyle(
            color: isFirst ? AppColors.primary : AppColors.onSurface,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
        Text(
          stat,
          style: const TextStyle(
            color: AppColors.outline,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 75,
          height: podiumHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isFirst
                  ? [AppColors.primary, AppColors.primaryContainer]
                  : [AppColors.surfaceBright, AppColors.surfaceContainerHighest],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: isFirst ? AppColors.onPrimary : AppColors.onSurface,
                fontWeight: FontWeight.w900,
                fontSize: 17,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardSection(BuildContext context, List<AthleteLeaderboardItem> athleteList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ATHLETE STANDINGS (${athleteList.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Live Calculations',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (athleteList.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No athletes match your filter.',
                style: TextStyle(color: AppColors.outline),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: athleteList.length,
            itemBuilder: (context, index) {
              final athlete = athleteList[index];
              final rank = athlete.rank;
              final isTop3 = rank <= 3;
              final isPrRecent = athlete.isPrRecent;
              final imageUrl = athlete.imageUrl;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: NeumorphicContainer(
                  padding: const EdgeInsets.all(14),
                  borderRadius: 16,
                  child: Row(
                    children: [
                      // Rank Box
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isTop3 ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                          border: isTop3 ? Border.all(color: AppColors.primary.withValues(alpha: 0.4)) : null,
                        ),
                        child: Center(
                          child: Text(
                            '#$rank',
                            style: TextStyle(
                              color: isTop3 ? AppColors.primary : AppColors.onSurfaceVariant,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Avatar
                      Container(
                        width: 42,
                        height: 42,
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
                                errorBuilder: (c, e, s) => Center(child: Text(athlete.avatarText)),
                              )
                            : Center(
                                child: Text(
                                  athlete.avatarText,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    athlete.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                if (isPrRecent) ...[
                                  const SizedBox(width: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'NEW PR',
                                      style: TextStyle(
                                        color: Color(0xFF00E676),
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
                              athlete.division,
                              style: const TextStyle(
                                color: AppColors.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              athlete.highlight,
                              style: const TextStyle(
                                color: AppColors.outline,
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Score & Streak
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            athlete.score,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            athlete.stat,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              athlete.streak,
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
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

  Widget _buildGymRecordsWall(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shield_outlined, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'IRON FORGE HALL OF FAME RECORDS',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.5,
          children: _gymRecords.map((rec) {
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
                      Text(
                        rec['title'] as String,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        rec['date'] as String,
                        style: const TextStyle(color: AppColors.outline, fontSize: 9),
                      ),
                    ],
                  ),
                  Text(
                    rec['val'] as String,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                  ),
                  Text(
                    rec['holder'] as String,
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLogPrActionCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official PR Verification',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Staff-witnessed lifts award +50 bonus points to our gym score in database.',
                      style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClayButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PR Verification Logger opened for Coach/Staff.'),
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
                Icon(Icons.add, color: AppColors.onPrimary, size: 18),
                SizedBox(width: 6),
                Text(
                  'Record & Verify Athlete PR',
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
