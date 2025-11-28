import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PaymentMethodButtonsWidget extends StatelessWidget {
  const PaymentMethodButtonsWidget({super.key});

  void _handlePaymentMethod(BuildContext context, String method) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening $method...'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final paymentMethods = [
      {'name': 'Venmo', 'icon': 'account_balance_wallet'},
      {'name': 'PayPal', 'icon': 'payment'},
      {'name': 'CashApp', 'icon': 'attach_money'},
      {'name': 'Apple Pay', 'icon': 'apple'},
      {'name': 'Google Pay', 'icon': 'g_mobiledata'},
    ];

    return Container(
      height: 10.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paymentMethods.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          return GestureDetector(
            onTap: () =>
                _handlePaymentMethod(context, method['name'] as String),
            child: Container(
              width: 20.w,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.dividerColor,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.shadow,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: method['icon'] as String,
                    size: 28,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    method['name'] as String,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
