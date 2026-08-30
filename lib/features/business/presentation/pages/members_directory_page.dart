import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/gym_model.dart';
import '../../../../providers/members_provider.dart';

class MembersDirectoryPage extends ConsumerStatefulWidget {
  const MembersDirectoryPage({super.key});

  @override
  ConsumerState<MembersDirectoryPage> createState() => _MembersDirectoryPageState();
}

class _MembersDirectoryPageState extends ConsumerState<MembersDirectoryPage> {
  int _selectedFilterIndex = 0; // 0: All, 1: Active, 2: Expiring, 3: At Risk, 4: Overdue
  int _selectedTierIndex = 0; // 0: All, 1: Elite, 2: Pro, 3: PT
  String _searchQuery = '';
  Timer? _debounceTimer;

  final List<String> _filters = ['All', 'Active', 'Expiring', 'At Risk', 'Overdue'];
  final List<String> _tiers = ['All Tiers', 'Elite Annual', 'Pro Tier', 'Personal Training'];

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


  @override
  Widget build(BuildContext context) {
    final membersAsync = ref.watch(gymMembersListProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: membersAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: ShimmerSkeleton(width: double.infinity, height: 300),
                ),
                error: (e, st) => Center(
                  child: Text('Error loading athletes: $e', style: const TextStyle(color: AppColors.outline)),
                ),
                data: (allMembers) {
                  final filteredMembers = allMembers.where((m) {
                    final name = (m.fullName ?? '').toLowerCase();
                    final id = m.memberCode.toLowerCase();
                    final phone = (m.phone ?? '').toLowerCase();
                    final query = _searchQuery.toLowerCase();

                    final matchesSearch = _searchQuery.isEmpty || name.contains(query) || id.contains(query) || phone.contains(query);

                    bool matchesFilter = true;
                    if (_selectedFilterIndex == 1) {
                      matchesFilter = m.status == 'active';
                    } else if (_selectedFilterIndex == 2) {
                      matchesFilter = m.status == 'expiring';
                    } else if (_selectedFilterIndex == 3) {
                      matchesFilter = m.status == 'at_risk';
                    } else if (_selectedFilterIndex == 4) {
                      matchesFilter = m.status == 'overdue';
                    }

                    bool matchesTier = true;
                    if (_selectedTierIndex == 1) {
                      matchesTier = (m.tierName ?? '').contains('Elite');
                    } else if (_selectedTierIndex == 2) {
                      matchesTier = (m.tierName ?? '').contains('Pro');
                    } else if (_selectedTierIndex == 3) {
                      matchesTier = (m.tierName ?? '').contains('Personal Training');
                    }

                    return matchesSearch && matchesFilter && matchesTier;
                  }).toList();

                  final expiringCount = allMembers.where((m) => m.status == 'expiring').length;
                  final overdueCount = allMembers.where((m) => m.status == 'overdue').length;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSearchBar(),
                        const SizedBox(height: 18),
                        _buildStatusFilters(allMembers.length),
                        const SizedBox(height: 14),
                        _buildTierChips(),
                        const SizedBox(height: 20),
                        _buildDirectoryOverviewBanner(context, allMembers.length, expiringCount, overdueCount),
                        const SizedBox(height: 24),
                        _buildMemberListHeader(context, filteredMembers.length),
                        const SizedBox(height: 14),
                        _buildMemberList(context, filteredMembers),
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMemberModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add_alt_1, color: AppColors.onPrimary),
        label: const Text(
          'Add Athlete',
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
                    'Athletes Directory',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Live Roster Sync',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting live roster to CSV...'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            child: const NeumorphicContainer(
              padding: EdgeInsets.all(8),
              borderRadius: 12,
              child: Icon(
                Icons.file_download_outlined,
                color: AppColors.primary,
                size: 20,
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
          hintText: 'Search by athlete name, ID, or phone...',
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

  Widget _buildStatusFilters(int total) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          final label = _filters[index];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
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
                  label,
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

  Widget _buildTierChips() {
    return Row(
      children: List.generate(_tiers.length, (index) {
        final isSelected = _selectedTierIndex == index;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedTierIndex = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              margin: EdgeInsets.only(right: index < _tiers.length - 1 ? 6 : 0),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                ),
              ),
              child: Center(
                child: Text(
                  _tiers[index],
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

  Widget _buildDirectoryOverviewBanner(BuildContext context, int total, int expiring, int overdue) {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildBannerItem(context, title: 'TOTAL ROSTER', value: '$total', icon: Icons.groups_outlined),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildBannerItem(context,
              title: 'EXPIRING 7D', value: '$expiring', icon: Icons.timer_outlined, valueColor: const Color(0xFFFFB74D)),
          Container(width: 1, height: 36, color: AppColors.outlineVariant),
          _buildBannerItem(context,
              title: 'OVERDUE DUES', value: '$overdue', icon: Icons.money_off, valueColor: AppColors.error),
        ],
      ),
    );
  }

  Widget _buildBannerItem(BuildContext context,
      {required String title, required String value, required IconData icon, Color? valueColor}) {
    return Column(
      children: [
        Icon(icon, color: valueColor ?? AppColors.outline, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w900,
                fontSize: 16,
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

  Widget _buildMemberListHeader(BuildContext context, int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'MEMBERS ROSTER ($count)',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
        ),
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Broadcasting WhatsApp reminder to filtered athletes...'),
                backgroundColor: AppColors.surfaceContainerHigh,
              ),
            );
          },
          child: const Row(
            children: [
              Icon(Icons.send_rounded, color: AppColors.primary, size: 13),
              SizedBox(width: 4),
              Text(
                'Broadcast Push',
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
    );
  }

  Widget _buildMemberList(BuildContext context, List<GymMemberModel> membersList) {
    if (membersList.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: Text(
            'No athletes found matching your search criteria.',
            style: TextStyle(color: AppColors.outline),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: membersList.length,
      itemBuilder: (context, index) {
        final member = membersList[index];
        final imageUrl = member.avatarUrl;
        final status = member.status;
        final statusColor = status == 'active'
            ? const Color(0xFF00E676)
            : status == 'expiring'
                ? const Color(0xFFFFB74D)
                : AppColors.error;

        final tier = member.tierName ?? 'Elite Annual';
        final tierColor = tier.contains('Elite') ? AppColors.primary : AppColors.secondary;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _showMemberDetailModal(context, member),
            child: NeumorphicContainer(
              padding: const EdgeInsets.all(14),
              borderRadius: 18,
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
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
                                errorBuilder: (c, e, s) => Center(child: Text(member.fullName?.substring(0, 1) ?? 'A')),
                              )
                            : Center(
                                child: Text(
                                  member.fullName?.substring(0, 1) ?? 'A',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  member.fullName ?? 'Athlete',
                                  style: const TextStyle(
                                    color: AppColors.onSurface,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Text(
                                  member.memberCode,
                                  style: const TextStyle(color: AppColors.outline, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: tierColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    tier,
                                    style: TextStyle(
                                      color: tierColor,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.person_pin, color: AppColors.outline, size: 13),
                                    const SizedBox(width: 4),
                                    Text(
                                      member.trainerName ?? 'Self-Guided',
                                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.flash_on, color: AppColors.primary, size: 13),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${member.totalCheckIns} check-ins',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Divider(color: AppColors.outlineVariant, height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Last Check-in: ${member.lastCheckIn ?? "Recent"}',
                        style: const TextStyle(color: AppColors.outline, fontSize: 10),
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Calling ${member.fullName} (${member.phone})...'),
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.call_outlined, color: AppColors.primary, size: 17),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening WhatsApp chat with ${member.fullName}...'),
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 6),
                              child: Icon(Icons.chat_bubble_outline, color: Color(0xFF00E676), size: 17),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right, color: AppColors.outline, size: 18),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMemberDetailModal(BuildContext context, GymMemberModel member) {
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.fullName ?? 'Athlete',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      Text(
                        'Member ID: ${member.memberCode} • ${member.tierName}',
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.outline),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _buildModalDetailRow('Contact Phone', member.phone ?? 'N/A'),
                    const Divider(color: AppColors.outlineVariant, height: 16),
                    _buildModalDetailRow('Membership Expiry', member.expiryDate ?? 'Active'),
                    const Divider(color: AppColors.outlineVariant, height: 16),
                    _buildModalDetailRow('Assigned Coach', member.trainerName ?? 'Self-Guided'),
                    const Divider(color: AppColors.outlineVariant, height: 16),
                    _buildModalDetailRow('Total Check-ins', '${member.totalCheckIns} sessions'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ClayButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Renewal invoice dispatched to ${member.fullName}'),
                            backgroundColor: AppColors.surfaceContainerHigh,
                          ),
                        );
                      },
                      height: 48,
                      borderRadius: 14,
                      color: AppColors.surfaceContainerHigh,
                      child: const Text(
                        'Send Invoice',
                        style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClayButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Check-in confirmed for ${member.fullName}!'),
                            backgroundColor: AppColors.surfaceContainerHigh,
                          ),
                        );
                      },
                      height: 48,
                      borderRadius: 14,
                      color: AppColors.primary,
                      child: const Text(
                        'Log Check-In',
                        style: TextStyle(color: AppColors.onPrimary, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 12)),
        Text(value, style: const TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700, fontSize: 12)),
      ],
    );
  }

  void _showAddMemberModal(BuildContext context) {
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
                    'Enroll New Athlete',
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
              const Text('Full Name', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. Sameer Khan',
                    hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Phone Number', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: '+91 98765 00000',
                    hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Athlete successfully enrolled and synced to database!'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Text(
                  'Confirm & Activate Membership',
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
            _buildNavItem(context, icon: Icons.group, label: 'Members', isActive: true, route: AppRoutes.membersDirectory),
            _buildNavItem(context, icon: Icons.fitness_center_outlined, label: 'Train', route: AppRoutes.personalTraining),
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
