import 'package:flutter/material.dart';
import '../models/invoice.dart';

class InvoiceStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const InvoiceStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildFilterChip(context, 'all', 'All', Icons.list),
          _buildFilterChip(context, InvoiceStatus.draft, 'Draft', Icons.edit),
          _buildFilterChip(context, InvoiceStatus.sent, 'Sent', Icons.send),
          _buildFilterChip(
            context,
            InvoiceStatus.paid,
            'Paid',
            Icons.check_circle,
          ),
          _buildFilterChip(context, 'unpaid', 'Unpaid', Icons.pending),
          _buildFilterChip(context, 'overdue', 'Overdue', Icons.warning),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedStatus == value;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        selected: isSelected,
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : theme.primaryColor,
            ),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
        onSelected: (_) => onStatusChanged(value),
        backgroundColor: Colors.grey[200],
        selectedColor: theme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
