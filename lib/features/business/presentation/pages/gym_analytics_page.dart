import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';

class GymAnalyticsPage extends StatefulWidget {
  const GymAnalyticsPage({super.key});

  @override
  State<GymAnalyticsPage> createState() => _GymAnalyticsPageState();
}

class _GymAnalyticsPageState extends State<GymAnalyticsPage> {
  int _selectedTimeframeIndex = 1; // 0: 7D, 1: 30D, 2: 3M, 3: 1Y
  int _selectedChartTab = 0; // 0: Footfall, 1: Revenue, 2: Retention
  int? _selectedHourlyIndex;

  final List<String> _timeframes = ['7D', '30D', '3M', '1Y'];

  final List<Map<String, dynamic>> _hourlyData = [
    {'time': '06:00', 'count': 32, 'capacity': 40},
    {'time': '08:00', 'count': 64, 'capacity': 80},
    {'time': '10:00', 'count': 42, 'capacity': 52},
    {'time': '12:00', 'count': 28, 'capacity': 35},
    {'time': '14:00', 'count': 22, 'capacity': 28},
    {'time': '16:00', 'count': 56, 'capacity': 70},
    {'time': '18:00', 'count': 94, 'capacity': 95}, // Peak
    {'time': '20:00', 'count': 78, 'capacity': 85},
    {'time': '22:00', 'count': 30, 'capacity': 38},
  ];

  final List<Map<String, dynamic>> _revenueDaily = [
    {'day': 'Mon', 'amount': '₹42K', 'val': 0.70},
    {'day': 'Tue', 'amount': '₹58K', 'val': 0.85},
    {'day': 'Wed', 'amount': '₹85K', 'val': 1.00}, // New subscriptions batch
    {'day': 'Thu', 'amount': '₹35K', 'val': 0.55},
    {'day': 'Fri', 'amount': '₹48K', 'val': 0.75},
    {'day': 'Sat', 'amount': '₹62K', 'val': 0.90},
    {'day': 'Sun', 'amount': '₹20K', 'val': 0.35},
  ];

  final List<Map<String, dynamic>> _weeklyFootfall = [
    {'day': 'Mon', 'count': 342, 'pct': 0.95},
    {'day': 'Tue', 'count': 320, 'pct': 0.88},
    {'day': 'Wed', 'count': 355, 'pct': 0.98},
    {'day': 'Thu', 'count': 310, 'pct': 0.86},
    {'day': 'Fri', 'count': 295, 'pct': 0.82},
    {'day': 'Sat', 'count': 260, 'pct': 0.72},
    {'day': 'Sun', 'count': 180, 'pct': 0.50},
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
                    _buildTimeframeSelector(),
                    const SizedBox(height: 24),
                    _buildKpiBentoGrid(context),
                    const SizedBox(height: 28),
                    _buildLiveCapacityCard(context),
                    const SizedBox(height: 28),
                    _buildChartAnalysisSection(context),
                    const SizedBox(height: 28),
                    _buildWeeklyTrendSection(context),
                    const SizedBox(height: 28),
                    _buildRevenueBreakdownSection(context),
                    const SizedBox(height: 28),
                    _buildZoneUtilizationSection(context),
                    const SizedBox(height: 28),
                    _buildTopTrainersSection(context),
                    const SizedBox(height: 28),
                    _buildAiInsightsSection(context),
                    const SizedBox(height: 28),
                    _buildExportActions(context),
                    const SizedBox(height: 40),
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
                    'Gym Analytics',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Performance & Flow Insights',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showFilterBottomSheet(context),
            child: const NeumorphicContainer(
              padding: EdgeInsets.all(8),
              borderRadius: 12,
              child: Icon(
                Icons.tune_outlined,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(6),
      borderRadius: 16,
      child: Row(
        children: List.generate(_timeframes.length, (index) {
          final isSelected = _selectedTimeframeIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTimeframeIndex = index;
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
                    _timeframes[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 13,
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

  Widget _buildKpiBentoGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXECUTIVE OVERVIEW',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.trending_up, color: AppColors.primary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    '+14.8% MoM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          children: [
            _buildAnalyticsCard(
              context,
              title: 'TOTAL REVENUE',
              value: '₹4.85L',
              subtitle: 'Target: ₹5.00L (97%)',
              icon: Icons.currency_rupee_rounded,
              accentColor: AppColors.primary,
              badgeText: '+16.2%',
              badgeColor: AppColors.primary,
              progress: 0.97,
            ),
            _buildAnalyticsCard(
              context,
              title: 'RETENTION RATE',
              value: '94.2%',
              subtitle: 'Churn: 14 members',
              icon: Icons.repeat_rounded,
              accentColor: const Color(0xFF66BB6A),
              badgeText: '+3.1%',
              badgeColor: const Color(0xFF66BB6A),
              progress: 0.942,
            ),
            _buildAnalyticsCard(
              context,
              title: 'DAILY FOOTFALL',
              value: '318',
              subtitle: 'Peak: 94 at 18:30',
              icon: Icons.people_alt_outlined,
              accentColor: AppColors.secondary,
              badgeText: '+24/day',
              badgeColor: AppColors.secondary,
              progress: 0.85,
            ),
            _buildAnalyticsCard(
              context,
              title: 'AVG WORKOUT',
              value: '68 min',
              subtitle: 'Consistency: 4.2d/wk',
              icon: Icons.timer_outlined,
              accentColor: AppColors.tertiary,
              badgeText: '+8 min',
              badgeColor: AppColors.tertiary,
              progress: 0.72,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnalyticsCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badgeText,
    required Color badgeColor,
    required double progress,
  }) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.onSurface,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.outline,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLiveCapacityCard(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color(0xFF00E676),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x6600E676),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'LIVE GYM CAPACITY',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Text(
                  'MODERATE LOAD',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '72',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                              ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '/ 110 MAX',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '65% occupied • Optimal workout flow',
                      style: TextStyle(
                        color: AppColors.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 68,
                  width: 68,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const CircularProgressIndicator(
                        value: 72 / 110,
                        strokeWidth: 7,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                      const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '65%',
                            style: TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'LOAD',
                            style: TextStyle(
                              color: AppColors.outline,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.access_time_filled, color: AppColors.secondary, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Peak rush predicted at 18:00 - 20:30 (approx 94 athletes)',
                    style: TextStyle(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartAnalysisSection(BuildContext context) {
    final chartTabs = ['Hourly Footfall', 'Daily Revenue', 'Member Flow'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'INTEL & DISTRIBUTION',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Real-Time Synced',
              style: TextStyle(
                color: AppColors.outline,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Chart Tab Switcher
        Row(
          children: List.generate(chartTabs.length, (index) {
            final isSelected = _selectedChartTab == index;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedChartTab = index;
                    _selectedHourlyIndex = null;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  margin: EdgeInsets.only(right: index < chartTabs.length - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      chartTabs[index],
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
        ),
        const SizedBox(height: 14),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedChartTab == 0
                        ? 'Today’s Rush Curve'
                        : _selectedChartTab == 1
                            ? 'Revenue Inflow by Day'
                            : 'Member Consistency Pattern',
                    style: const TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  if (_selectedHourlyIndex != null && _selectedChartTab == 0)
                    Text(
                      '${_hourlyData[_selectedHourlyIndex!]['time']}: ${_hourlyData[_selectedHourlyIndex!]['count']} Athletes',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_selectedChartTab == 0) _buildHourlyBarChart(),
              if (_selectedChartTab == 1) _buildRevenueDailyChart(),
              if (_selectedChartTab == 2) _buildMemberFlowChart(),
              const SizedBox(height: 12),
              const Divider(color: AppColors.outlineVariant, height: 1),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.outline, size: 13),
                      SizedBox(width: 4),
                      Text(
                        'Tap any bar to inspect',
                        style: TextStyle(color: AppColors.outline, fontSize: 10),
                      ),
                    ],
                  ),
                  Text(
                    _selectedChartTab == 0
                        ? 'Peak Slot: 18:00 - 19:30'
                        : _selectedChartTab == 1
                            ? 'Top Day: Wednesday'
                            : 'Highest Retention: Tier 1',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHourlyBarChart() {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_hourlyData.length, (index) {
          final item = _hourlyData[index];
          final count = item['count'] as int;
          final isPeak = count >= 90;
          final isSelected = _selectedHourlyIndex == index;
          final heightFactor = count / 100.0;

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedHourlyIndex = index;
                });
              },
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPeak)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PEAK',
                          style: TextStyle(
                            color: AppColors.onPrimary,
                            fontSize: 7,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 100 * heightFactor,
                      width: isSelected ? 20 : 14,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isSelected
                              ? [AppColors.primaryFixed, AppColors.primary]
                              : isPeak
                                  ? [AppColors.primary, AppColors.primaryContainer]
                                  : [
                                      AppColors.surfaceBright,
                                      AppColors.surfaceContainerHighest,
                                    ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: isSelected || isPeak
                            ? [
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['time'] as String,
                      style: TextStyle(
                        color: isSelected
                            ? AppColors.primary
                            : isPeak
                                ? AppColors.onSurface
                                : AppColors.outline,
                        fontSize: 9,
                        fontWeight: isSelected || isPeak ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildRevenueDailyChart() {
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(_revenueDaily.length, (index) {
          final item = _revenueDaily[index];
          final val = item['val'] as double;
          final amount = item['amount'] as String;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: const TextStyle(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 90 * val,
                  width: 16,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.primary, AppColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item['day'] as String,
                  style: const TextStyle(
                    color: AppColors.onSurface,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMemberFlowChart() {
    return SizedBox(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFlowRow('Elite 1-Year Pass', '142 members', 0.88, AppColors.primary),
          _buildFlowRow('Quarterly Pro', '68 members', 0.65, AppColors.secondary),
          _buildFlowRow('Monthly Standard', '38 members', 0.42, const Color(0xFFEEC05B)),
        ],
      ),
    );
  }

  Widget _buildFlowRow(String label, String count, double factor, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: factor,
              minHeight: 10,
              backgroundColor: AppColors.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          count,
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildWeeklyTrendSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WEEKLY CONSISTENCY & HEATMAP',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Weekly Attendance Flow',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Avg 294 / day',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              ...List.generate(_weeklyFootfall.length, (index) {
                final item = _weeklyFootfall[index];
                final count = item['count'] as int;
                final pct = item['pct'] as double;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 34,
                        child: Text(
                          item['day'] as String,
                          style: TextStyle(
                            color: pct > 0.85 ? AppColors.onSurface : AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: pct,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: pct > 0.90
                                      ? [AppColors.primaryFixed, AppColors.primary]
                                      : [AppColors.secondaryContainer, AppColors.secondary],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 52,
                        child: Text(
                          '$count visits',
                          textAlign: TextAlign.end,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRevenueBreakdownSection(BuildContext context) {
    final revenueStreams = [
      {'name': 'Elite Membership', 'amount': '₹2.45L', 'pct': '51%', 'color': AppColors.primary},
      {'name': 'Pro Tier Passes', 'amount': '₹1.40L', 'pct': '29%', 'color': AppColors.secondary},
      {'name': 'Personal Coaching', 'amount': '₹68,000', 'pct': '14%', 'color': const Color(0xFFEEC05B)},
      {'name': 'Fuel Bar & Merch', 'amount': '₹32,000', 'pct': '6%', 'color': AppColors.outline},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REVENUE STREAM COMPOSITION',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Inflow',
                        style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                      Text(
                        '₹4,85,000',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  ClayButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.paymentsMemberships);
                    },
                    height: 38,
                    width: 120,
                    borderRadius: 12,
                    color: AppColors.surfaceContainerHigh,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Text(
                      'Manage Billing',
                      style: TextStyle(
                        color: AppColors.onSurface,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Segmented Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: const SizedBox(
                  height: 12,
                  child: Row(
                    children: [
                      Expanded(flex: 51, child: ColoredBox(color: AppColors.primary)),
                      SizedBox(width: 2),
                      Expanded(flex: 29, child: ColoredBox(color: AppColors.secondary)),
                      SizedBox(width: 2),
                      Expanded(flex: 14, child: ColoredBox(color: Color(0xFFEEC05B))),
                      SizedBox(width: 2),
                      Expanded(flex: 6, child: ColoredBox(color: AppColors.outline)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ...revenueStreams.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: item['color'] as Color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            item['name'] as String,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            item['amount'] as String,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '(${item['pct']})',
                            style: const TextStyle(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildZoneUtilizationSection(BuildContext context) {
    final zones = [
      {'name': 'Free Weights & Power Racks', 'usage': '45%', 'val': 0.45, 'icon': Icons.fitness_center},
      {'name': 'Cable & Machine Sector', 'usage': '28%', 'val': 0.28, 'icon': Icons.view_compact_rounded},
      {'name': 'Cardio & Conditioning Deck', 'usage': '17%', 'val': 0.17, 'icon': Icons.directions_run_rounded},
      {'name': 'Recovery & Mobility Suite', 'usage': '10%', 'val': 0.10, 'icon': Icons.self_improvement_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ZONE & EQUIPMENT UTILIZATION',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            children: zones.map((zone) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(zone['icon'] as IconData, color: AppColors.primary, size: 16),
                            const SizedBox(width: 10),
                            Text(
                              zone['name'] as String,
                              style: const TextStyle(
                                color: AppColors.onSurface,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          zone['usage'] as String,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: zone['val'] as double,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTopTrainersSection(BuildContext context) {
    final trainers = [
      {
        'name': 'Coach Vikram Rathore',
        'specialty': 'Strength & Hypertrophy',
        'clients': 24,
        'rating': '4.95',
        'satisfaction': '98%',
      },
      {
        'name': 'Coach Ananya Roy',
        'specialty': 'Functional & Endurance',
        'clients': 19,
        'rating': '4.91',
        'satisfaction': '96%',
      },
      {
        'name': 'Coach Arjun Verma',
        'specialty': 'Powerlifting & Form',
        'clients': 15,
        'rating': '4.88',
        'satisfaction': '94%',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COACHING & TRAINER EFFICIENCY',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.personalTraining);
              },
              child: const Text(
                'View All',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...trainers.map((trainer) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 16,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHighest,
                    ),
                    child: Center(
                      child: Text(
                        (trainer['name'] as String).split(' ')[1][0],
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          trainer['name'] as String,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          trainer['specialty'] as String,
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
                      Row(
                        children: [
                          const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                          const SizedBox(width: 2),
                          Text(
                            trainer['rating'] as String,
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${trainer['clients']} active athletes',
                        style: const TextStyle(
                          color: AppColors.outline,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAiInsightsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              'AI GYM INTELLIGENCE',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1.2,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '14 High Churn-Risk Members',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Athletes who haven’t logged a session in 10+ days. Activating them now saves ~₹42,000 in monthly revenue.',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.35,
                          ),
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
                      content: Text('Win-back campaign triggered for 14 at-risk athletes!'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 44,
                borderRadius: 12,
                color: AppColors.primary,
                child: const Text(
                  'Trigger Win-Back WhatsApp Push',
                  style: TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        NeumorphicContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.lightbulb_outline, color: AppColors.secondary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Off-Peak Morning Slot Incentive',
                          style: TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '10:00 - 12:00 has 70% surplus capacity. Running a 15% discount for morning-only passes could shift 22 evening members.',
                          style: TextStyle(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportActions(BuildContext context) {
    return Column(
      children: [
        ClayButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Generating Comprehensive Monthly Audit PDF...'),
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            );
          },
          height: 52,
          borderRadius: 16,
          color: AppColors.surfaceContainerHigh,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.file_download_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 10),
              Text(
                'Download Full Performance Report',
                style: TextStyle(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Analytics Filters',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.outline),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Branch Location', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Iron Forge - Main Arena (Sector 14)', style: TextStyle(color: AppColors.onSurface)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Metrics Included', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Footfall', 'Revenue', 'Coaching', 'Equipment', 'Churn']
                    .map((item) => Chip(
                          label: Text(item),
                          backgroundColor: AppColors.surfaceContainerHigh,
                          labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 12),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () => Navigator.pop(context),
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
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
            _buildNavItem(context, icon: Icons.analytics, label: 'Analytics', isActive: true, route: AppRoutes.gymAnalytics),
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
