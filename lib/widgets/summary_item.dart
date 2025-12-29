import 'package:flutter/material.dart';

class SummaryItem extends StatelessWidget {
  final String label;
  final String? totalAmountUsdt;
  final String? totalAmountBdt;
  final Color color;

  const SummaryItem({
    super.key,
    required this.label,
    this.totalAmountUsdt,
    this.totalAmountBdt,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        const SizedBox(height: 4),
        if (totalAmountUsdt != null) ...[
          Text(
            "₮$totalAmountUsdt",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
        if (totalAmountBdt != null) ...[
          Text(
            "৳$totalAmountBdt",
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ],
    );
  }
}
