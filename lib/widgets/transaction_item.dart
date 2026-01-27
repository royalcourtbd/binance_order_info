import 'dart:async';
import 'package:binance_order_info/models/transaction_item_model.dart';
import 'package:binance_order_info/screens/transaction_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionItem extends StatefulWidget {
  final TransactionItemModel transaction;

  const TransactionItem({super.key, required this.transaction});

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  Timer? _timer;
  Duration _remainingTime = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateRemainingTime();
    _startTimer();
  }

  /// Calculate remaining time from 24-hour window
  void _calculateRemainingTime() {
    if (widget.transaction.createTime == null) return;

    final createDateTime = DateTime.fromMillisecondsSinceEpoch(
      widget.transaction.createTime!,
    );
    final expiryTime = createDateTime.add(const Duration(hours: 24));
    final now = DateTime.now();

    if (expiryTime.isAfter(now)) {
      _remainingTime = expiryTime.difference(now);
    } else {
      _remainingTime = Duration.zero;
    }
  }

  /// Start periodic timer to update countdown every second
  void _startTimer() {
    // Only start timer for BUY transactions within 24-hour window
    if (!_isBuy || _remainingTime == Duration.zero) return;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  /// Check if transaction is BUY type
  bool get _isBuy => widget.transaction.category.toUpperCase() == 'BUY';

  /// Check if timer should be displayed
  bool get _shouldShowTimer => _isBuy && _remainingTime.inSeconds > 0;

  /// Format remaining time as HH:MM:SS
  String get _formattedTime {
    final hours = _remainingTime.inHours;
    final minutes = _remainingTime.inMinutes.remainder(60);
    final seconds = _remainingTime.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Build countdown timer widget
  Widget _buildTimerWidget() {
    if (!_shouldShowTimer) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _formattedTime,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBuy = widget.transaction.category.toUpperCase() == 'BUY';
    final transactionColor = isBuy ? Colors.blue : Colors.red;

    return InkWell(
      onTap: () {
        Get.to(
          () => TransactionDetailsScreen(transaction: widget.transaction),
          transition: Transition.rightToLeft,
          duration: const Duration(milliseconds: 300),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: transactionColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.transaction.category,
                style: TextStyle(
                  color: transactionColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.transaction.title,
                    style: const TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  Text(
                    widget.transaction.method,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  // Timer widget - শুধু BUY transactions এ দেখাবে
                  _buildTimerWidget(),
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (widget.transaction.cryptoAmount != null &&
                      widget.transaction.asset != null)
                    Text(
                      "${widget.transaction.getDisplayCryptoAmount()} ${widget.transaction.asset}",
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    "${widget.transaction.fiatSymbol ?? '৳'} ${double.tryParse(widget.transaction.totalPrice)?.toStringAsFixed(2) ?? widget.transaction.totalPrice}",
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: transactionColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (widget.transaction.actualRate > 0 &&
                      widget.transaction.manualCharge != null)
                    Text(
                      "@${widget.transaction.actualRate.toStringAsFixed(2)}",
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
