import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../core/localization/app_localizations.dart';

class TransactionFilter extends StatelessWidget {
  final String? selectedType;
  final String? selectedMethod;
  final String? selectedStatus;
  final String? selectedInquiry;

  final Function({
  String? type,
  String? method,
  String? status,
  String? inquiry,
  }) onFilterChanged;

  const TransactionFilter({
    super.key,
    required this.selectedType,
    required this.selectedMethod,
    required this.selectedStatus,
    required this.selectedInquiry,
    required this.onFilterChanged,
  });

  static const List<String> _transactionTypes = [
    'Deposit',
    'Purchase',
    'Refund',
    'Withdraw',
    'Adjustment',
    'AutoRenew',
  ];

  static const List<String> _transactionMethods = ['System', 'Wallet', 'QRPayment'];
  static const List<String> _transactionStatuses = ['Pending', 'Completed', 'Expired', 'Cancelled'];
  static const List<String> _inquiryOptions = ['Yes', 'No'];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context: context,
                label: loc.translate("type"),
                value: selectedType,
                items: _transactionTypes,
                onChanged: (val) => onFilterChanged(
                  type: val,
                  method: selectedMethod,
                  status: selectedStatus,
                  inquiry: selectedInquiry,
                ),
                allLabel: loc.translate("all"),
              ),
            ),
            SizedBox(width: sw(context, 8)),
            Expanded(
              child: _buildDropdown(
                context: context,
                label: loc.translate("method"),
                value: selectedMethod,
                items: _transactionMethods,
                onChanged: (val) => onFilterChanged(
                  type: selectedType,
                  method: val,
                  status: selectedStatus,
                  inquiry: selectedInquiry,
                ),
                allLabel: loc.translate("all"),
              ),
            ),
          ],
        ),
        SizedBox(height: sh(context, 8)),
        Row(
          children: [
            Expanded(
              child: _buildDropdown(
                context: context,
                label: loc.translate("status"),
                value: selectedStatus,
                items: _transactionStatuses,
                onChanged: (val) => onFilterChanged(
                  type: selectedType,
                  method: selectedMethod,
                  status: val,
                  inquiry: selectedInquiry,
                ),
                allLabel: loc.translate("all"),
              ),
            ),
            SizedBox(width: sw(context, 8)),
            Expanded(
              child: _buildDropdown(
                context: context,
                label: loc.translate("inquiry"),
                value: selectedInquiry,
                items: _inquiryOptions,
                onChanged: (val) => onFilterChanged(
                  type: selectedType,
                  method: selectedMethod,
                  status: selectedStatus,
                  inquiry: val,
                ),
                allLabel: loc.translate("all"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    required String allLabel,
  }) {
    final loc = AppLocalizations.of(context);
    final dropdownItems = [allLabel, ...items];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dropdownBackground = isDark ? Colors.grey[800] : Colors.grey[300];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 4),
        DropdownButton2<String>(
          isExpanded: true,
          value: value ?? allLabel,
          items: dropdownItems
              .map((item) => DropdownMenuItem<String>(
            value: item,
            child: Text(
              item == allLabel ? item : loc.translate(item.toLowerCase()),
              overflow: TextOverflow.ellipsis,
            ),
          ))
              .toList(),
          onChanged: (val) {
            onChanged(val == allLabel ? null : val);
          },
          buttonStyleData: ButtonStyleData(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
              color: Colors.transparent,
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            maxHeight: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: dropdownBackground,
              border: Border.all(color: Colors.white),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      ],
    );
  }
}
