import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/neumorphic_container.dart';
import '../../../../core/widgets/clay_button.dart';
import '../../../../core/widgets/shimmer_skeleton.dart';
import '../../../../models/payment_model.dart';
import '../../../../providers/payments_provider.dart';

class PaymentsMembershipsPage extends ConsumerStatefulWidget {
  const PaymentsMembershipsPage({super.key});

  @override
  ConsumerState<PaymentsMembershipsPage> createState() => _PaymentsMembershipsPageState();
}

class _PaymentsMembershipsPageState extends ConsumerState<PaymentsMembershipsPage> {
  int _selectedLedgerTab = 0; // 0: All, 1: Successful, 2: Overdue / Pending, 3: Auto-Debit
  int _selectedViewSegment = 0; // 0: Transactions, 1: Membership Plans

  final List<String> _ledgerTabs = ['All', 'Success', 'Overdue', 'Auto-Debit'];

  @override
  Widget build(BuildContext context) {
    final paymentsAsync = ref.watch(paymentsListProvider);
    final plansAsync = ref.watch(membershipPlansProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: paymentsAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(20),
                  child: ShimmerSkeleton(width: double.infinity, height: 300),
                ),
                error: (e, st) => Center(
                  child: Text('Error loading payments: $e', style: const TextStyle(color: AppColors.outline)),
                ),
                data: (allPayments) {
                  final filteredTransactions = allPayments.where((t) {
                    if (_selectedLedgerTab == 1) {
                      return t.status == 'paid';
                    } else if (_selectedLedgerTab == 2) {
                      return t.status == 'overdue' || t.status == 'pending';
                    } else if (_selectedLedgerTab == 3) {
                      return t.paymentMethod.contains('auto') || t.paymentMethod.contains('card');
                    }
                    return true;
                  }).toList();

                  final totalCollected = allPayments
                      .where((p) => p.status == 'paid')
                      .fold<double>(0.0, (acc, p) => acc + p.amount);

                  final totalOverdue = allPayments
                      .where((p) => p.status == 'overdue')
                      .fold<double>(0.0, (acc, p) => acc + p.amount);

                  final overdueCount = allPayments.where((p) => p.status == 'overdue').length;

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMonthPeriodSelector(context),
                        const SizedBox(height: 20),
                        _buildFinancialKpiGrid(context, totalCollected, totalOverdue, overdueCount),
                        const SizedBox(height: 24),
                        _buildQuickActionButtons(context, overdueCount),
                        const SizedBox(height: 26),
                        _buildSegmentSwitcher(),
                        const SizedBox(height: 20),
                        if (_selectedViewSegment == 0) ...[
                          _buildLedgerTabs(allPayments.length),
                          const SizedBox(height: 16),
                          _buildTransactionsList(context, filteredTransactions),
                        ] else ...[
                          plansAsync.when(
                            loading: () => const ShimmerSkeleton(width: double.infinity, height: 200),
                            error: (e, st) => Text('Error loading plans: $e'),
                            data: (plans) => _buildMembershipPlansSection(context, plans),
                          ),
                        ],
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
        onPressed: () => _showCollectPaymentModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.currency_rupee, color: AppColors.onPrimary),
        label: const Text(
          'Collect / Invoice',
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
                    'Payments & Billing',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                  ),
                  Text(
                    'Live Inflows & Ledger',
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
                  content: Text('Opening QR POS Terminal for front-desk collection...'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            child: const NeumorphicContainer(
              padding: EdgeInsets.all(8),
              borderRadius: 12,
              child: Icon(
                Icons.qr_code_scanner,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPeriodSelector(BuildContext context) {
    return NeumorphicContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Cycle Inflow',
                    style: TextStyle(
                      color: AppColors.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Realtime Database Sync',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'LIVE LEDGER',
              style: TextStyle(
                color: Color(0xFF00E676),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialKpiGrid(BuildContext context, double collected, double overdue, int overdueCount) {
    final revenueInLakhs = (collected / 100000).toStringAsFixed(2);
    final overdueInK = (overdue / 1000).toStringAsFixed(1);

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: [
        _buildFinanceCard(
          context,
          title: 'COLLECTED REVENUE',
          value: '₹${revenueInLakhs}L',
          subtitle: 'Real Paid Payments',
          icon: Icons.account_balance_wallet_outlined,
          color: AppColors.primary,
          badge: 'Live Sum',
        ),
        _buildFinanceCard(
          context,
          title: 'OVERDUE DUES',
          value: '₹${overdueInK}K',
          subtitle: '$overdueCount Invoices Unpaid',
          icon: Icons.warning_amber_rounded,
          color: AppColors.error,
          badge: 'Action Needed',
        ),
        _buildFinanceCard(
          context,
          title: 'UPCOMING RENEWALS',
          value: '₹64.0K',
          subtitle: 'Next 7 Days',
          icon: Icons.autorenew,
          color: AppColors.secondary,
          badge: '12 Athletes',
        ),
        _buildFinanceCard(
          context,
          title: 'ARPU / ATHLETE',
          value: '₹1,955',
          subtitle: 'Active Member Avg',
          icon: Icons.trending_up,
          color: const Color(0xFF66BB6A),
          badge: 'Optimal',
        ),
      ],
    );
  }

  Widget _buildFinanceCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String badge,
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
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
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
                      fontWeight: FontWeight.w900,
                      color: AppColors.onSurface,
                      fontSize: 20,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.outline,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButtons(BuildContext context, int overdueCount) {
    return Row(
      children: [
        Expanded(
          child: ClayButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Auto-reminders sent to $overdueCount members with overdue dues.'),
                  backgroundColor: AppColors.surfaceContainerHigh,
                ),
              );
            },
            height: 44,
            borderRadius: 14,
            color: AppColors.errorContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.mark_email_unread_outlined, color: AppColors.onErrorContainer, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Send $overdueCount Overdue Reminders',
                  style: const TextStyle(
                    color: AppColors.onErrorContainer,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSegmentSwitcher() {
    return NeumorphicContainer(
      padding: const EdgeInsets.all(4),
      borderRadius: 14,
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedViewSegment = 0;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedViewSegment == 0 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Billing Ledger',
                    style: TextStyle(
                      color: _selectedViewSegment == 0 ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: _selectedViewSegment == 0 ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedViewSegment = 1;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _selectedViewSegment == 1 ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'Membership Plans',
                    style: TextStyle(
                      color: _selectedViewSegment == 1 ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                      fontWeight: _selectedViewSegment == 1 ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedgerTabs(int totalCount) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_ledgerTabs.length, (index) {
          final isSelected = _selectedLedgerTab == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedLedgerTab = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.surfaceContainerHighest : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  _ledgerTabs[index],
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTransactionsList(BuildContext context, List<PaymentModel> items) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No transactions in this filter.', style: TextStyle(color: AppColors.outline)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final tx = items[index];
        final isOverdue = tx.status == 'overdue';
        final statusColor = tx.status == 'paid' ? const Color(0xFF00E676) : AppColors.error;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(14),
            borderRadius: 16,
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isOverdue ? AppColors.errorContainer.withValues(alpha: 0.2) : AppColors.surfaceContainerHighest,
                  ),
                  child: Center(
                    child: Text(
                      tx.avatarText ?? 'IF',
                      style: TextStyle(
                        color: isOverdue ? AppColors.error : AppColors.primary,
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
                          Text(
                            tx.userName ?? 'Athlete',
                            style: const TextStyle(
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            tx.invoiceNumber,
                            style: const TextStyle(color: AppColors.outline, fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.tierName ?? 'Membership Pass',
                        style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.payment, size: 12, color: isOverdue ? AppColors.error : AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            tx.paymentMethod,
                            style: TextStyle(
                              color: isOverdue ? AppColors.error : AppColors.outline,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Amount & Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${tx.amount.toInt()}',
                      style: TextStyle(
                        color: isOverdue ? AppColors.error : AppColors.onSurface,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tx.status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
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
    );
  }

  Widget _buildMembershipPlansSection(BuildContext context, List<MembershipPlanModel> plans) {
    return Column(
      children: plans.map((plan) {
        final color = plan.tierType == 'elite'
            ? AppColors.primary
            : plan.tierType == 'pro'
                ? AppColors.secondary
                : const Color(0xFFEEC05B);

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: NeumorphicContainer(
            padding: const EdgeInsets.all(18),
            borderRadius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          plan.name,
                          style: const TextStyle(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (plan.isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MOST POPULAR',
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
                    Text(
                      '${plan.activeMembers} active',
                      style: const TextStyle(color: AppColors.outline, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '₹${plan.price.toInt()}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                    ),
                    Text(
                      ' / ${plan.durationMonths} Mo',
                      style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                    ),
                    const Spacer(),
                    Text(
                      '${plan.revenueShare} share',
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppColors.outlineVariant, height: 1),
                const SizedBox(height: 12),
                ...plan.features.map((feat) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Icon(Icons.check_circle_outline, color: color, size: 15),
                        const SizedBox(width: 8),
                        Text(
                          feat,
                          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Editing settings for ${plan.name}'),
                              backgroundColor: AppColors.surfaceContainerHigh,
                            ),
                          );
                        },
                        height: 38,
                        borderRadius: 12,
                        color: AppColors.surfaceContainerHigh,
                        child: const Text(
                          'Edit Pricing & Perks',
                          style: TextStyle(color: AppColors.onSurface, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showCollectPaymentModal(BuildContext context) {
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
                    'Collect Member Payment',
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
                    Text('Arjun Verma (#IF-1042)', style: TextStyle(color: AppColors.onSurface, fontSize: 13)),
                    Icon(Icons.keyboard_arrow_down, color: AppColors.primary),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Amount to Collect (₹)', style: TextStyle(color: AppColors.onSurface, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const TextField(
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'e.g. 24000',
                    hintStyle: TextStyle(color: AppColors.outline, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ClayButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.invalidate(paymentsListProvider);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment of ₹24,000 received & recorded to live database!'),
                      backgroundColor: AppColors.surfaceContainerHigh,
                    ),
                  );
                },
                height: 48,
                borderRadius: 14,
                color: AppColors.primary,
                child: const Text(
                  'Confirm & Generate Digital Receipt',
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
            _buildNavItem(context, icon: Icons.leaderboard_outlined, label: 'Ranks', route: AppRoutes.gymRankings),
            _buildNavItem(context, icon: Icons.payments, label: 'Pay', isActive: true, route: AppRoutes.paymentsMemberships),
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
