import 'package:flutter/material.dart';

/// Text field for asset code with QR scan button.
class AssetCodeField extends StatefulWidget {
  final String? value;
  final String? errorMessage;
  final void Function(String) onChanged;
  final Future<void> Function() onScan;

  const AssetCodeField({
    super.key,
    this.value,
    this.errorMessage,
    required this.onChanged,
    required this.onScan,
  });

  @override
  State<AssetCodeField> createState() => _AssetCodeFieldState();
}

class _AssetCodeFieldState extends State<AssetCodeField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value ?? '');
  }

  @override
  void didUpdateWidget(AssetCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      _controller.text = widget.value ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Asset Code *',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.errorMessage != null
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              hintText: 'Enter asset code',
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  Icons.qr_code_scanner,
                  color: Theme.of(context).primaryColor,
                ),
                onPressed: widget.onScan,
              ),
            ),
          ),
        ),
        if (widget.errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              widget.errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
