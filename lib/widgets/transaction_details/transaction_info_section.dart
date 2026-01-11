import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:binance_order_info/widgets/transaction_details/copyable_detail_row.dart';
import 'package:binance_order_info/widgets/transaction_details/detail_row.dart';
import 'package:binance_order_info/widgets/transaction_details/transaction_divider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionInfoSection extends StatelessWidget {
  final TransactionItemModel transaction;

  const TransactionInfoSection({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isBuy = transaction.category.toUpperCase() == 'BUY';
    final transactionColor = isBuy ? Colors.blue : Colors.red;

    return Container(
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
          CopyableDetailRow(
            'Order Number',
            transaction.title.replaceFirst('#', ''),
          ),
          if (transaction.advNo != null) ...[
            const TransactionDivider(),
            DetailRow('Advertisement No', transaction.advNo!),
          ],
          const TransactionDivider(),
          DetailRow('Payment Method', transaction.method),
          if (transaction.orderStatus != null) ...[
            const TransactionDivider(),
            DetailRow(
              'Order Status',
              transaction.orderStatus!,
              statusColor: _getStatusColor(transaction.orderStatus!),
            ),
          ],
          if (transaction.counterPartNickName != null) ...[
            const TransactionDivider(),
            DetailRow(
              'Counter Party',
              transaction.counterPartNickName!,
            ),
          ],
          const TransactionDivider(),
          DetailRow(
            'Transaction Type',
            transaction.category.toUpperCase(),
            valueColor: transactionColor,
          ),
          if (transaction.asset != null) ...[
            const TransactionDivider(),
            DetailRow('Asset', transaction.asset!),
          ],
          if (transaction.createTime != null) ...[
            const TransactionDivider(),
            DetailRow(
              'Date & Time',
              _formatFullDateTime(transaction.createTime!),
            ),
          ],
          if (transaction.additionalKycVerify != null) ...[
            const TransactionDivider(),
            DetailRow(
              'KYC Verified',
              transaction.additionalKycVerify! ? 'Yes' : 'No',
              statusColor: transaction.additionalKycVerify!
                  ? Colors.green
                  : Colors.grey,
            ),
          ],
        ],
      ),
    );
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
}
