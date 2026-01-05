import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import '../controllers/orders_controller.dart';
import '../widgets/manual_charge_dialog.dart';

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

        return _buildBody(context, currentTransaction, controller);
      }),
    );
  }

  Widget _buildBody(BuildContext context, TransactionItemModel transaction, OrdersController controller) {
    final isBuy = transaction.category.toUpperCase() == 'BUY';
    final transactionColor = isBuy ? Colors.blue : Colors.red;

    return SingleChildScrollView(
        child: Column(
          children: [
            // Header Section - Transaction Type Badge
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: transactionColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      transaction.category.toUpperCase(),
                      style: TextStyle(
                        color: transactionColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (transaction.createTime != null)
                    Text(
                      _formatDateTime(transaction.createTime!),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Amount Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Price',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        "${transaction.fiatSymbol ?? '৳'} ${double.tryParse(transaction.totalPrice)?.toStringAsFixed(2) ?? transaction.totalPrice}",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: transactionColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (transaction.fiat != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            transaction.fiat!,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (transaction.cryptoAmount != null &&
                      transaction.asset != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (transaction.category.toUpperCase() == 'BUY') ...[
                            _buildAmountDetailRow(
                              'Receive Quantity',
                              '${transaction.getReceivedQuantity()} ${transaction.asset}',
                              isHighlighted: true,
                            ),
                            const SizedBox(height: 8),
                            _buildAmountDetailRow(
                              'Total Quantity',
                              '${transaction.getTotalQuantity()} ${transaction.asset}',
                            ),
                            if (transaction.unitPrice != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Unit Price',
                                '${double.tryParse(transaction.unitPrice!)?.toStringAsFixed(2) ?? transaction.unitPrice} ${transaction.fiat ?? ''}',
                              ),
                            ],
                            if (transaction.effectiveCommission != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Fee (${transaction.effectiveCommissionLabel})',
                                '${double.tryParse(transaction.effectiveCommission!)?.toStringAsFixed(2) ?? transaction.effectiveCommission} ${transaction.asset}',
                                valueColor: Colors.orange,
                              ),
                            ],
                            if (transaction.manualCharge != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Manual Charge',
                                '${transaction.manualCharge!.toStringAsFixed(2)} ${transaction.fiat ?? 'BDT'}',
                                valueColor: Colors.deepOrange,
                              ),
                            ],
                          ] else ...[
                            _buildAmountDetailRow(
                              'Total Quantity',
                              '${transaction.getDisplayCryptoAmount()} ${transaction.asset}',
                              isHighlighted: true,
                            ),
                            const SizedBox(height: 8),
                            _buildAmountDetailRow(
                              'Release Quantity',
                              '${transaction.getTotalQuantity()} ${transaction.asset}',
                            ),
                            if (transaction.unitPrice != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Unit Price',
                                '${double.tryParse(transaction.unitPrice!)?.toStringAsFixed(2) ?? transaction.unitPrice} ${transaction.fiat ?? ''}',
                              ),
                            ],
                            if (transaction.effectiveCommission != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Fee (${transaction.effectiveCommissionLabel})',
                                '${double.tryParse(transaction.effectiveCommission!)?.toStringAsFixed(2) ?? transaction.effectiveCommission} ${transaction.asset}',
                                valueColor: Colors.orange,
                              ),
                            ],
                            if (transaction.manualCharge != null) ...[
                              const SizedBox(height: 8),
                              _buildAmountDetailRow(
                                'Manual Charge',
                                '${transaction.manualCharge!.toStringAsFixed(2)} ${transaction.fiat ?? 'BDT'}',
                                valueColor: Colors.deepOrange,
                              ),
                            ],
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Transaction Details Section
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildCopyableDetailRow(
                    context,
                    'Order Number',
                    transaction.title.replaceFirst('#', ''),
                  ),
                  if (transaction.advNo != null) ...[
                    _buildDivider(),
                    _buildDetailRow('Advertisement No', transaction.advNo!),
                  ],
                  _buildDivider(),
                  _buildDetailRow('Payment Method', transaction.method),
                  if (transaction.orderStatus != null) ...[
                    _buildDivider(),
                    _buildDetailRow('Order Status', transaction.orderStatus!,
                        statusColor: _getStatusColor(transaction.orderStatus!)),
                  ],
                  if (transaction.counterPartNickName != null) ...[
                    _buildDivider(),
                    _buildDetailRow(
                        'Counter Party', transaction.counterPartNickName!),
                  ],
                  _buildDivider(),
                  _buildDetailRow(
                    'Transaction Type',
                    transaction.category.toUpperCase(),
                    valueColor: transactionColor,
                  ),
                  if (transaction.asset != null) ...[
                    _buildDivider(),
                    _buildDetailRow('Asset', transaction.asset!),
                  ],
                  if (transaction.createTime != null) ...[
                    _buildDivider(),
                    _buildDetailRow(
                      'Date & Time',
                      _formatFullDateTime(transaction.createTime!),
                    ),
                  ],
                  if (transaction.additionalKycVerify != null) ...[
                    _buildDivider(),
                    _buildDetailRow(
                      'KYC Verified',
                      transaction.additionalKycVerify! ? 'Yes' : 'No',
                      statusColor: transaction.additionalKycVerify!
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      );
  }

  Widget _buildAmountDetailRow(String label, String value,
      {Color? valueColor, bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 14 : 13,
            color: valueColor ?? (isHighlighted ? Colors.black87 : Colors.grey[700]),
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCopyableDetailRow(BuildContext context, String label, String value,
      {Color? valueColor, Color? statusColor}) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: value));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$label copied to clipboard'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                    child: statusColor != null
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              value,
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 14,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          )
                        : Text(
                            value,
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 14,
                              color: valueColor ?? Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.copy,
                    size: 16,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value,
      {Color? valueColor, Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: statusColor != null
                ? Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 14,
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 14,
                      color: valueColor ?? Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
    );
  }

  String _formatDateTime(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('MMM dd, yyyy • hh:mm a').format(date);
  }

  String _formatFullDateTime(int milliseconds) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return DateFormat('EEEE, MMMM dd, yyyy • hh:mm:ss a').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'COMPLETED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'CANCELLED':
      case 'FAILED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Show dialog to add/edit manual charge
  void _showManualChargeDialog(
      BuildContext context, OrdersController controller) async {
    final isBuy = transaction.category.toUpperCase() == 'BUY';
    final orderNumber = transaction.title.replaceFirst('#', '');

    final result = await showDialog(
      context: context,
      builder: (context) => ManualChargeDialog(
        isBuy: isBuy,
        currentCharge: transaction.manualCharge,
      ),
    );

    if (result == null) return; // User cancelled

    if (result == 'remove') {
      // Remove the manual charge
      final success = await controller.removeManualCharge(orderNumber);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Manual charge removed successfully'
                : 'Failed to remove manual charge'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } else if (result is double) {
      // Save the manual charge
      final success = await controller.saveManualCharge(orderNumber, result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success
                ? 'Manual charge saved successfully'
                : 'Failed to save manual charge'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }
}
