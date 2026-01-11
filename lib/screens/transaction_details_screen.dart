import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../widgets/manual_charge_dialog.dart';
import '../widgets/transaction_details/transaction_details_body.dart';

class TransactionDetailsScreen extends StatelessWidget {
  final TransactionItemModel transaction;

  const TransactionDetailsScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrdersController>();
    final orderNumber = transaction.title.replaceFirst('#', '');

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Transaction Details',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          // Edit button to add/edit manual charge
          IconButton(
            icon: const Icon(Icons.edit_note),
            tooltip: 'Edit Manual Charge',
            onPressed: () => _showManualChargeDialog(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        // Get the latest transaction data from controller
        final currentTransaction =
            controller.getTransactionByOrderNumber(orderNumber) ?? transaction;

        return TransactionDetailsBody(transaction: currentTransaction);
      }),
    );
  }

  /// Show dialog to add/edit manual charge
  void _showManualChargeDialog(
    BuildContext context,
    OrdersController controller,
  ) async {
    final isBuy = transaction.category.toUpperCase() == 'BUY';
    final orderNumber = transaction.title.replaceFirst('#', '');

    final result = await ManualChargeDialog.show(
      context,
      isBuy: isBuy,
      currentCharge: transaction.manualCharge,
    );

    if (result == null) return; // User cancelled

    if (result == 'remove') {
      // Remove the manual charge
      final success = await controller.removeManualCharge(orderNumber);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Manual charge removed successfully'
                  : 'Failed to remove manual charge',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } else if (result is double) {
      final success = await controller.saveManualCharge(orderNumber, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Manual charge saved successfully'
                  : 'Failed to save manual charge',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
