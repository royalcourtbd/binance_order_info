import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:binance_order_info/widgets/transaction_details/amount_detail_row.dart';
import 'package:flutter/material.dart';

class AmountSection extends StatelessWidget {
  final TransactionItemModel transaction;

  const AmountSection({super.key, required this.transaction});

  /// Build manual charge string with percentage
  String _buildManualChargeWithPercentage(TransactionItemModel transaction) {
    final manualCharge = transaction.manualCharge!;
    final totalPrice = double.tryParse(transaction.totalPrice) ?? 0.0;

    if (totalPrice > 0) {
      final percentage = (manualCharge / totalPrice) * 100;
      return '${manualCharge.toStringAsFixed(2)} ${transaction.fiat ?? 'BDT'} (${percentage.toStringAsFixed(2)}%)';
    }

    return '${manualCharge.toStringAsFixed(2)} ${transaction.fiat ?? 'BDT'}';
  }

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
                    AmountDetailRow(
                      'Receive Quantity',
                      '${transaction.getReceivedQuantity()} ${transaction.asset}',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    AmountDetailRow(
                      'Total Quantity',
                      '${transaction.getTotalQuantity()} ${transaction.asset}',
                    ),
                    if (transaction.unitPrice != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Unit Price',
                        '${double.tryParse(transaction.unitPrice!)?.toStringAsFixed(2) ?? transaction.unitPrice} ${transaction.fiat ?? ''}',
                      ),
                    ],
                    if (transaction.effectiveCommission != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Fee (${transaction.effectiveCommissionLabel})',
                        '${double.tryParse(transaction.effectiveCommission!)?.toStringAsFixed(2) ?? transaction.effectiveCommission} ${transaction.asset}',
                        valueColor: Colors.orange,
                      ),
                    ],
                    if (transaction.manualCharge != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Manual Charge',
                        _buildManualChargeWithPercentage(transaction),
                        valueColor: Colors.deepOrange,
                      ),
                    ],
                  ] else ...[
                    AmountDetailRow(
                      'Total Quantity',
                      '${transaction.getDisplayCryptoAmount()} ${transaction.asset}',
                      isHighlighted: true,
                    ),
                    const SizedBox(height: 8),
                    AmountDetailRow(
                      'Release Quantity',
                      '${transaction.getTotalQuantity()} ${transaction.asset}',
                    ),
                    if (transaction.unitPrice != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Unit Price',
                        '${double.tryParse(transaction.unitPrice!)?.toStringAsFixed(2) ?? transaction.unitPrice} ${transaction.fiat ?? ''}',
                      ),
                    ],
                    if (transaction.effectiveCommission != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Fee (${transaction.effectiveCommissionLabel})',
                        '${double.tryParse(transaction.effectiveCommission!)?.toStringAsFixed(2) ?? transaction.effectiveCommission} ${transaction.asset}',
                        valueColor: Colors.orange,
                      ),
                    ],
                    if (transaction.manualCharge != null) ...[
                      const SizedBox(height: 8),
                      AmountDetailRow(
                        'Manual Charge',
                        _buildManualChargeWithPercentage(transaction),
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
    );
  }
}
