import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dialog for entering manual charge amount
/// Shows appropriate instructions based on transaction type (BUY/SELL)
class ManualChargeDialog extends StatelessWidget {
  final bool isBuy; // true for BUY, false for SELL
  final double? currentCharge; // Current charge value (if already set)

  const ManualChargeDialog({
    super.key,
    required this.isBuy,
    this.currentCharge,
  });

  /// Shows the manual charge dialog and returns the result
  /// Returns null if cancelled, 'remove' if charge removed, or double value if saved
  static Future<dynamic> show(
    BuildContext context, {
    required bool isBuy,
    double? currentCharge,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ManualChargeDialog(
        isBuy: isBuy,
        currentCharge: currentCharge,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isBuy ? Colors.blue : Colors.red;
    final transactionType = isBuy ? 'BUY' : 'SELL';
    final instruction = isBuy
        ? 'আপনি dollar কেনার সময় যে extra charge (BDT) দিয়েছেন সেটা লিখুন'
        : 'Buyer আপনাকে যে extra charge (BDT) দিয়েছে সেটা লিখুন';

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
      child: ManualChargeDialogContent(
        isBuy: isBuy,
        currentCharge: currentCharge,
        color: color,
        transactionType: transactionType,
        instruction: instruction,
      ),
    );
  }
}

class ManualChargeDialogContent extends StatefulWidget {
  final bool isBuy;
  final double? currentCharge;
  final Color color;
  final String transactionType;
  final String instruction;

  const ManualChargeDialogContent({
    super.key,
    required this.isBuy,
    required this.currentCharge,
    required this.color,
    required this.transactionType,
    required this.instruction,
  });

  @override
  State<ManualChargeDialogContent> createState() => _ManualChargeDialogContentState();
}

class _ManualChargeDialogContentState extends State<ManualChargeDialogContent> {
  late final TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Pre-fill with current charge if exists
    if (widget.currentCharge != null) {
      _controller.text = widget.currentCharge!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: widget.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.transactionType,
                      style: TextStyle(
                        color: widget.color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Manual Charge',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Instruction
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.instruction,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Input field
              TextFormField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}'),
                  ),
                ],
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Charge Amount (৳)',
                  hintText: '0.00',
                  prefixIcon: const Icon(Icons.money),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'দয়া করে amount লিখুন';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'সঠিক number লিখুন';
                  }
                  if (amount < 0) {
                    return 'Amount 0 এর কম হতে পারবে না';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Remove button (if charge already exists)
                  if (widget.currentCharge != null) ...[
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop('remove');
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Cancel button
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Save button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final amount = double.parse(_controller.text);
                        Navigator.of(context).pop(amount);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.color,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
