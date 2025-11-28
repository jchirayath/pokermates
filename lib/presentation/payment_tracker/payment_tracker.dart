import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/filter_segment_widget.dart';
import './widgets/payment_item_widget.dart';
import './widgets/payment_method_buttons_widget.dart';
import './widgets/summary_card_widget.dart';

class PaymentTracker extends StatefulWidget {
  const PaymentTracker({super.key});

  @override
  State<PaymentTracker> createState() => _PaymentTrackerState();
}

class _PaymentTrackerState extends State<PaymentTracker> {
  int _currentBottomIndex = 3;
  String _selectedFilter = 'All';
  String _selectedGroup = 'All Groups';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Mock data for payments
  final List<Map<String, dynamic>> _payments = [
    {
      "id": 1,
      "playerName": "Michael Rodriguez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e13bc62a-1763294059113.png",
      "semanticLabel":
          "Profile photo of a man with short brown hair and a beard, wearing a dark t-shirt",
      "amount": 150.00,
      "type": "owed_to_me",
      "gameReference": "Friday Night Poker - Nov 22",
      "dueDate": DateTime.now().subtract(const Duration(days: 2)),
      "status": "Pending",
      "paymentMethod": "Venmo",
      "isOverdue": true,
    },
    {
      "id": 2,
      "playerName": "Sarah Chen",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1449dc50a-1763299855187.png",
      "semanticLabel":
          "Profile photo of an Asian woman with long black hair, wearing glasses and a white blouse",
      "amount": 75.50,
      "type": "i_owe",
      "gameReference": "Weekend Tournament - Nov 24",
      "dueDate": DateTime.now().add(const Duration(days: 3)),
      "status": "Sent",
      "paymentMethod": "PayPal",
      "isOverdue": false,
    },
    {
      "id": 3,
      "playerName": "James Wilson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_116c94415-1763295713677.png",
      "semanticLabel":
          "Profile photo of a man with gray hair and blue eyes, wearing a navy polo shirt",
      "amount": 200.00,
      "type": "owed_to_me",
      "gameReference": "Monthly Championship - Nov 20",
      "dueDate": DateTime.now().subtract(const Duration(days: 5)),
      "status": "Pending",
      "paymentMethod": "CashApp",
      "isOverdue": true,
    },
    {
      "id": 4,
      "playerName": "Emily Thompson",
      "avatar":
          "https://images.unsplash.com/photo-1632852301600-05943e4bf450",
      "semanticLabel":
          "Profile photo of a woman with blonde hair in a ponytail, wearing a green sweater",
      "amount": 125.00,
      "type": "i_owe",
      "gameReference": "Thursday Game Night - Nov 23",
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "status": "Pending",
      "paymentMethod": "Apple Pay",
      "isOverdue": false,
    },
    {
      "id": 5,
      "playerName": "David Martinez",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_14b497383-1763293672321.png",
      "semanticLabel":
          "Profile photo of a Hispanic man with short black hair, wearing a red checkered shirt",
      "amount": 90.00,
      "type": "completed",
      "gameReference": "Weekend Poker - Nov 18",
      "dueDate": DateTime.now().subtract(const Duration(days: 8)),
      "status": "Completed",
      "paymentMethod": "Venmo",
      "isOverdue": false,
    },
    {
      "id": 6,
      "playerName": "Lisa Anderson",
      "avatar":
          "https://img.rocket.new/generatedImages/rocket_gen_img_10dc6c8f9-1763296048231.png",
      "semanticLabel":
          "Profile photo of a woman with curly brown hair, wearing a purple cardigan",
      "amount": 180.00,
      "type": "owed_to_me",
      "gameReference": "Friday Night Poker - Nov 22",
      "dueDate": DateTime.now().add(const Duration(days: 2)),
      "status": "Pending",
      "paymentMethod": "Google Pay",
      "isOverdue": false,
    },
  ];

  List<Map<String, dynamic>> get _filteredPayments {
    List<Map<String, dynamic>> filtered = _payments;

    // Apply filter
    if (_selectedFilter != 'All') {
      if (_selectedFilter == 'Owed to Me') {
        filtered = filtered.where((p) => p['type'] == 'owed_to_me').toList();
      } else if (_selectedFilter == 'I Owe') {
        filtered = filtered.where((p) => p['type'] == 'i_owe').toList();
      } else if (_selectedFilter == 'Completed') {
        filtered = filtered.where((p) => p['type'] == 'completed').toList();
      }
    }

    // Apply search
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final name = (p['playerName'] as String).toLowerCase();
        final amount = p['amount'].toString();
        final game = (p['gameReference'] as String).toLowerCase();
        final query = _searchQuery.toLowerCase();
        return name.contains(query) ||
            amount.contains(query) ||
            game.contains(query);
      }).toList();
    }

    return filtered;
  }

  double get _totalOwedToMe {
    return _payments
        .where((p) => p['type'] == 'owed_to_me')
        .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
  }

  double get _totalIOwe {
    return _payments
        .where((p) => p['type'] == 'i_owe')
        .fold(0.0, (sum, p) => sum + (p['amount'] as num).toDouble());
  }

  double get _netPosition {
    return _totalOwedToMe - _totalIOwe;
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomIndex = index;
    });
  }

  void _handleFilterChange(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
  }

  void _handleSearch(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  void _handleSendReminder(Map<String, dynamic> payment) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder sent to ${payment['playerName']}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleMarkPaid(Map<String, dynamic> payment) {
    setState(() {
      payment['status'] = 'Completed';
      payment['type'] = 'completed';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment marked as completed'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleEditAmount(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => _buildEditAmountDialog(payment),
    );
  }

  Widget _buildEditAmountDialog(Map<String, dynamic> payment) {
    final theme = Theme.of(context);
    final TextEditingController amountController = TextEditingController(
      text: payment['amount'].toString(),
    );

    return AlertDialog(
      title: Text('Edit Amount', style: theme.textTheme.titleLarge),
      content: TextField(
        controller: amountController,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Amount',
          prefixText: '\$ ',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              payment['amount'] =
                  double.tryParse(amountController.text) ?? payment['amount'];
            });
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Amount updated successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  void _handleRequestPayment() {
    showDialog(
      context: context,
      builder: (context) => _buildRequestPaymentDialog(),
    );
  }

  Widget _buildRequestPaymentDialog() {
    final theme = Theme.of(context);
    final TextEditingController amountController = TextEditingController();
    final TextEditingController messageController = TextEditingController();

    return AlertDialog(
      title: Text('Request Payment', style: theme.textTheme.titleLarge),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Amount',
              prefixText: '\$ ',
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: messageController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Message (Optional)',
              hintText: 'Add a note about this payment...',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Payment request sent successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          child: const Text('Send Request'),
        ),
      ],
    );
  }

  void _handleExportHistory() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment history exported successfully'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment statuses synced'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Payment Tracker',
        variant: AppBarVariant.standard,
        actions: [
          AppBarAction(
            icon: Icons.file_download_outlined,
            onPressed: _handleExportHistory,
            tooltip: 'Export History',
          ),
          AppBarAction(
            icon: Icons.add_circle_outline,
            onPressed: _handleRequestPayment,
            tooltip: 'Request Payment',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),
                  SummaryCardWidget(
                    totalOwedToMe: _totalOwedToMe,
                    totalIOwe: _totalIOwe,
                    netPosition: _netPosition,
                  ),
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.dividerColor,
                          width: 1,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _handleSearch,
                        decoration: InputDecoration(
                          hintText: 'Search by player, amount, or game...',
                          prefixIcon: CustomIconWidget(
                            iconName: 'search',
                            color: theme.colorScheme.onSurfaceVariant,
                            size: 20,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: CustomIconWidget(
                                    iconName: 'close',
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _handleSearch('');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.5.h,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  FilterSegmentWidget(
                    selectedFilter: _selectedFilter,
                    onFilterChanged: _handleFilterChange,
                  ),
                  SizedBox(height: 2.h),
                  PaymentMethodButtonsWidget(),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
            _filteredPayments.isEmpty
                ? SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'payments_outlined',
                            size: 64,
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No payments found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Try adjusting your filters or search',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final payment = _filteredPayments[index];
                        return PaymentItemWidget(
                          payment: payment,
                          onSendReminder: () => _handleSendReminder(payment),
                          onMarkPaid: () => _handleMarkPaid(payment),
                          onEditAmount: () => _handleEditAmount(payment),
                        );
                      },
                      childCount: _filteredPayments.length,
                    ),
                  ),
            SliverToBoxAdapter(
              child: SizedBox(height: 2.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: _handleBottomNavTap,
        variant: BottomBarVariant.standard,
      ),
    );
  }
}
