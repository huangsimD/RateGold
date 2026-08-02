import 'package:flutter/material.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/theme/app_colors.dart';

Future<String?> showCurrencyPickerSheet(
  BuildContext context, {
  required List<String> codes,
  String? selectedCode,
  String? title,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _CurrencyPickerSheet(
      codes: codes,
      selectedCode: selectedCode,
      title: title,
    ),
  );
}

class _CurrencyPickerSheet extends StatefulWidget {
  const _CurrencyPickerSheet({
    required this.codes,
    required this.title,
    this.selectedCode,
  });

  final List<String> codes;
  final String? selectedCode;
  final String? title;

  @override
  State<_CurrencyPickerSheet> createState() => _CurrencyPickerSheetState();
}

class _CurrencyPickerSheetState extends State<_CurrencyPickerSheet> {
  late List<String> _filtered;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.of(widget.codes);
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch() {
    final l10n = context.l10nRead;
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filtered = List.of(widget.codes);
      } else {
        _filtered = widget.codes.where((code) {
          final name = l10n.currencyName(code).toLowerCase();
          return code.toLowerCase().contains(query) || name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final maxHeight = MediaQuery.sizeOf(context).height * 0.75;
    final sheetTitle = widget.title ?? l10n.selectCurrency;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      sheetTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: l10n.searchCurrency,
                  prefixIcon: const Icon(Icons.search, size: 20),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: _filtered.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          l10n.noCurrenciesFound,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filtered.length,
                      itemBuilder: (context, index) {
                        final code = _filtered[index];
                        final selected = code == widget.selectedCode;
                        return ListTile(
                          selected: selected,
                          title: Text(code),
                          subtitle: Text(l10n.currencyName(code)),
                          trailing: selected
                              ? const Icon(Icons.check, color: AppColors.primary)
                              : null,
                          onTap: () => Navigator.pop(context, code),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
