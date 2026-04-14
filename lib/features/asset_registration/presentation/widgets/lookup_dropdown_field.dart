import 'package:flutter/material.dart';

/// Reusable dropdown field for lookup data with an add button.
class LookupDropdownField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final String? selectedValue;
  final String? errorMessage;
  final void Function(String?) onChanged;
  final void Function() onAddNew;
  final String Function(T) getItemId;
  final String Function(T) getItemLabel;

  const LookupDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.selectedValue,
    this.errorMessage,
    required this.onChanged,
    required this.onAddNew,
    required this.getItemId,
    required this.getItemLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAddNew,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.add,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: errorMessage != null
                  ? Theme.of(context).colorScheme.error
                  : Colors.grey.shade300,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedValue,
            items: items
                .map((item) => DropdownMenuItem<String>(
                      value: getItemId(item),
                      child: Text(getItemLabel(item)),
                    ))
                .toList(),
            onChanged: onChanged,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text('Select $label'),
            ),
            underline: const SizedBox(),
            padding: const EdgeInsets.symmetric(horizontal: 12),
          ),
        ),
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              errorMessage!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }
}
