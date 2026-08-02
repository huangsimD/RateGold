import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rategold/data/currency_catalog.dart';
import 'package:rategold/l10n/app_strings.dart';
import 'package:rategold/l10n/l10n_extensions.dart';
import 'package:rategold/services/board_controller.dart';
import 'package:rategold/theme/app_colors.dart';

class ManageFavoritesScreen extends StatefulWidget {
  const ManageFavoritesScreen({super.key});

  @override
  State<ManageFavoritesScreen> createState() => _ManageFavoritesScreenState();
}

class _ManageFavoritesScreenState extends State<ManageFavoritesScreen> {
  late List<String> _favorites;
  final _searchController = TextEditingController();
  String _query = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _favorites = List.of(context.read<BoardController>().snapshot.favoriteCodes);
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<String> _addableCodes(AppStrings l10n) {
    return CurrencyCatalog.allCodes.where((code) {
      if (_favorites.contains(code)) return false;
      if (_query.isEmpty) return true;
      final name = l10n.currencyName(code).toLowerCase();
      return code.toLowerCase().contains(_query) || name.contains(_query);
    }).toList();
  }

  Future<void> _save() async {
    final l10n = context.l10nRead;
    if (_favorites.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.keepOneFavorite)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await context.read<BoardController>().updateFavoriteCodes(_favorites);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _remove(String code) {
    final l10n = context.l10nRead;
    if (_favorites.length <= 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.keepOneFavorite)),
      );
      return;
    }
    setState(() => _favorites.remove(code));
  }

  void _add(String code) {
    final l10n = context.l10nRead;
    if (_favorites.length >= CurrencyCatalog.maxFavorites) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.maxFavoritesMessage(CurrencyCatalog.maxFavorites))),
      );
      return;
    }
    setState(() => _favorites.add(code));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final max = CurrencyCatalog.maxFavorites;
    final addable = _addableCodes(l10n);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.manageFavoritesTitle),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(l10n.done),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(
            l10n.favoritesCount(_favorites.length, max),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Material(
            color: AppColors.surfaceContainer,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _favorites.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex -= 1;
                  final item = _favorites.removeAt(oldIndex);
                  _favorites.insert(newIndex, item);
                });
              },
              itemBuilder: (context, index) {
                final code = _favorites[index];
                return ListTile(
                  key: ValueKey(code),
                  leading: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle),
                  ),
                  title: Text(code),
                  subtitle: Text(l10n.currencyName(code)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => _remove(code),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(l10n.addCurrencySection, style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.searchToAdd,
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (addable.isEmpty)
            Text(
              _query.isEmpty ? l10n.allCurrenciesAdded : l10n.noMatches,
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final code in addable)
                  ActionChip(
                    avatar: const Icon(Icons.add, size: 18),
                    label: Text(code),
                    onPressed: () => _add(code),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
