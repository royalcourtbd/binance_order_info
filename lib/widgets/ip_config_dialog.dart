import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/api_config.dart';

class IpConfigDialog extends StatefulWidget {
  final VoidCallback onIpChanged;

  const IpConfigDialog({super.key, required this.onIpChanged});

  @override
  State<IpConfigDialog> createState() => _IpConfigDialogState();
}

class _IpConfigDialogState extends State<IpConfigDialog> {
  final TextEditingController _ipController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentIp();
  }

  Future<void> _loadCurrentIp() async {
    final currentIp = await ApiConfig.getIpAddress();
    _ipController.text = currentIp;
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  String? _validateIp(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an IP address';
    }

    // Basic IP validation
    final ipPattern = RegExp(
      r'^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$',
    );

    if (!ipPattern.hasMatch(value)) {
      return 'Invalid IP format (e.g., 192.168.0.101)';
    }

    // Check each octet is between 0-255
    final parts = value.split('.');
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'Each number must be between 0 and 255';
      }
    }

    return null;
  }

  Future<void> _saveIp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ApiConfig.setIpAddress(_ipController.text.trim());

      if (mounted) {
        Get.back();
        Get.snackbar(
          'Success',
          'IP address updated to ${_ipController.text.trim()}',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
          duration: const Duration(seconds: 2),
        );

        // Call the callback to refresh orders
        widget.onIpChanged();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save IP address: $e',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(10),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Server IP Configuration',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your server IP address:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _ipController,
              decoration: InputDecoration(
                hintText: '192.168.0.101',
                prefixIcon: const Icon(Icons.computer),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
              ),
              keyboardType: TextInputType.number,
              validator: _validateIp,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 10),
            const Text(
              'Format: xxx.xxx.xxx.xxx\nPort: 8000 (default)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Get.back(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveIp,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
