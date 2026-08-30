import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/personal_training_model.dart';
import '../../../../providers/pt_provider.dart';

class PersonalTrainingPage extends ConsumerStatefulWidget {
  const PersonalTrainingPage({super.key});

  @override
  ConsumerState<PersonalTrainingPage> createState() => _PersonalTrainingPageState();
}

class _PersonalTrainingPageState extends ConsumerState<PersonalTrainingPage> {
  int _selectedSegmentIndex = 0; // 0: Coaches, 1: Today's Schedule, 2: Client Roster

  @override
  Widget build(BuildContext context) {
    final coachesAsync = ref.watch(coachesListProvider);
    final sessionsAsync = ref.watch(todaySessionsProvider);
    final clientsAsync = ref.watch(ptClientsProvider);

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
                    coachesAsync.when(
                      loading: () => const ShimmerSkeleton(width: double.infinity, height: 60),
                      error: (e, st) => const SizedBox.shrink(),
                      data: (coaches) => _buildPtKpiOverview(context, coaches),
                    ),
                    const SizedBox(height: 24),
                    _buildSegmentSwitcher(),
                    const SizedBox(height: 20),
                    if (_selectedSegmentIndex == 0) ...[
                      coachesAsync.when(
                        loading: () => const ShimmerSkeleton(width: double.infinity, height: 250),
                        error: (e, st) => Text('Error: $e'),
                        data: (coaches) => _buildCoachesList(context, coaches),
                      ),
                    ] else if (_selectedSegmentIndex == 1) ...[
                      sessionsAsync.when(
                        loading: () => const ShimmerSkeleton(width: double.infinity, height: 250),
                        error: (e, st) => Text('Error: $e'),
                        data: (sessions) => _buildScheduleTimeline(context, sessions),
                      ),
                    ] else ...[
                      clientsAsync.when(
                        loading: () => const ShimmerSkeleton(width: double.infinity, height: 250),
                        error: (e, st) => Text('Error: $e'),
                        data: (clients) => _buildClientsRoster(context, clients),
                      ),
                    ],
                    const SizedBox(height: 28),
                    _buildBookSessionBanner(context),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBookSessionModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task, color: AppColors.onPrimary),
        label: const Text(
          'Book PT Session',
          style: TextStyle(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w800,
            fontSize: 13,
          ),
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
                    'Personal Training',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Live Coaching & Schedules',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _showAssignCoachModal(context),
            child: const NeumorphicContainer(
              padding: EdgeInsets.all(8),
              borderRadius: 12,
              child: Icon(
                Icons.person_add_alt,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPtKpiOverview(BuildContext context, List<CoachModel> coaches) {
    final totalClients = coaches.fold<int>(0, (sum, c) => sum + c.clients);
    final maxCapacity = coaches.fold<int>(0, (sum, c) => sum + c.maxClients);

    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPtStatItem(context, title: 'PT REVENUE', value: '₹1.16L', icon: Icons.currency_rupee, color: AppColors.primary),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildPtStatItem(context, title: 'CLIENT LOAD', value: '$totalClients / $maxCapacity', icon: Icons.groups_outlined),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildPtStatItem(context, title: 'SATISFACTION', value: '4.92 ★', icon: Icons.star, color: const Color(0xFF66BB6A)),
        ],
      ),
    );
  }

  Widget _buildPtStatItem(BuildContext context,
      {required String title, required String value, required IconData icon, Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? AppColors.outline, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: color ?? AppColors.onSurface,
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

  Widget _buildSegmentSwitcher() {
    final segments = ['Coaches', 'Today\'s Floor', 'Clients'];

    return NeumorphicContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 14,
      child: Row(
        children: List.generate(segments.length, (index) {
          final isSelected = _selectedSegmentIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSegmentIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    segments[index],
                    style: TextStyle(
                      color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 11,
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

  Widget _buildCoachesList(BuildContext context, List<CoachModel> coaches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'COACHING STAFF DIRECTORY (${coaches.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Active Allocation',
              style: TextStyle(color: AppColors.primary, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: coaches.length,
          itemBuilder: (context, index) {
            final coach = coaches[index];
            final capacityFactor = (coach.clients / coach.maxClients).clamp(0.0, 1.0);

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(16),
                borderRadius: 18,
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.surfaceContainerHighest,
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Center(
                            child: Text(
                              coach.avatarText,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    coach.name,
                                    style: const TextStyle(
                                      color: AppColors.onSurface,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      const Icon(Icons.star_rounded, color: AppColors.primary, size: 16),
                                      const SizedBox(width: 2),
                                      Text(
                                        coach.rating,
                                        style: const TextStyle(
                                          color: AppColors.onSurface,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                coach.role,
                                style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Focus: ${coach.specialty}',
                                style: const TextStyle(color: AppColors.outline, fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Capacity Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Client Load: ${coach.clients} / ${coach.maxClients} Active Slots',
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        Text(
                          coach.revenue,
                          style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: capacityFactor,
                        minHeight: 6,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: AppColors.outlineVariant, height: 1),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${coach.sessionsThisMonth} sessions logged this month',
                          style: const TextStyle(color: AppColors.outline, fontSize: 10),
                        ),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Calling ${coach.name} (${coach.phone})...'),
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.call_outlined, color: AppColors.primary, size: 16),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Opening chat with ${coach.name}...'),
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                  ),
                                );
                              },
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6),
                                child: Icon(Icons.chat_bubble_outline, color: Color(0xFF00E676), size: 16),
                              ),
                            ),
                          ],
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

  Widget _buildScheduleTimeline(BuildContext context, List<PtSessionModel> sessions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'TODAY\'S FLOOR SESSIONS (${sessions.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Live Status',
              style: TextStyle(color: AppColors.outline, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sessions.length,
          itemBuilder: (context, index) {
            final session = sessions[index];
            final isCompleted = session.status == 'Completed';
            final isInProgress = session.status == 'In Progress';
            final statusColor = isCompleted
                ? const Color(0xFF00E676)
                : isInProgress
                    ? AppColors.primary
                    : const Color(0xFFFFB74D);

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: Text(
                          session.avatarText,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                session.athleteName,
                                style: const TextStyle(
                                  color: AppColors.onSurface,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: statusColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  session.status,
                                  style: TextStyle(
                                    color: statusColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${session.coachName} • ${session.time}',
                            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            session.focus,
                            style: const TextStyle(color: AppColors.outline, fontSize: 10, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
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

  Widget _buildClientsRoster(BuildContext context, List<PtClientModel> clients) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACTIVE PT ATHLETES (${clients.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 1.2,
                  ),
            ),
            const Text(
              'Enrolled Clients',
              style: TextStyle(color: AppColors.outline, fontSize: 11),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: clients.length,
          itemBuilder: (context, index) {
            final client = clients[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeumorphicContainer(
                padding: const EdgeInsets.all(14),
                borderRadius: 16,
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
                                  client.avatarText,
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  client.name,
                                  style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                Text(
                                  client.coach,
                                  style: const TextStyle(color: AppColors.outline, fontSize: 10),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          client.sessionsLeft,
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      client.program,
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: client.progress,
                        minHeight: 4,
                        backgroundColor: AppColors.surfaceContainerHighest,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Renewal: ${client.renewalDue}',
                      style: TextStyle(
                        color: client.renewalDue.contains('Renew Now')
                            ? AppColors.error
                            : AppColors.outline,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildBookSessionBanner(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'COACHING ALLOCATION INSIGHT',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Coach Vikram is at 96% client capacity. Consider routing new powerlifting athletes to Coach Arjun to optimize floor load.',
            style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 14),
          ClayButton(
            onPressed: () => _showAssignCoachModal(context),
            height: 42,
            borderRadius: 12,
            color: AppColors.surfaceContainerHigh,
            child: const Text(
              'Rebalance Coach Roster',
              style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookSessionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Book 1-on-1 PT Session',
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
              const Text('Select Athlete', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Arjun Verma (Hypertrophy Block A)', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Assigned Coach', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Coach Vikram Rathore', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Time Slot', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                children: ['06:30 AM', '08:00 AM', '11:00 AM', '05:30 PM', '07:00 PM']
                    .map((time) => Chip(
                          label: Text(time),
                          backgroundColor: AppColors.surfaceContainerHigh,
                          labelStyle: const TextStyle(color: AppColors.onSurface, fontSize: 11),
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('PT Session scheduled & synced to live database!'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Text(
                  'Confirm & Schedule Session',
                  style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAssignCoachModal(BuildContext context) {
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
              Text(
                'Assign Athlete to Coach',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 16),
              const Text('Select Athlete', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Tanya Malik (#IF-1120)', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('New Assigned Coach', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Coach Arjun Verma (15/18 slots)', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Athlete successfully reassigned to Coach Arjun in database!'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Text(
                  'Update Coach Assignment',
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
            _buildNavItem(context, icon: Icons.fitness_center, label: 'Train', isActive: true, route: AppRoutes.personalTraining),
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Ranks', route: AppRoutes.gymRankings),
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
