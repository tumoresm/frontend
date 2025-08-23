import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Search bar widget for filtering notifications by text
class NotificationSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final String? initialQuery;

  const NotificationSearchBar({
    super.key,
    required this.onSearchChanged,
    this.initialQuery,
  });

  @override
  State<NotificationSearchBar> createState() => _NotificationSearchBarState();
}

class _NotificationSearchBarState extends State<NotificationSearchBar> {
  late TextEditingController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _isExpanded = widget.initialQuery?.isNotEmpty ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (!_isExpanded) {
        _controller.clear();
        widget.onSearchChanged('');
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: _isExpanded ? 56 : 48,
      child: Row(
        children: [
          if (!_isExpanded) ...[
            // Collapsed state - just search icon
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: InkWell(
                  onTap: _toggleSearch,
                  borderRadius: BorderRadius.circular(24),
                  child: Row(
                    children: [
                      const SizedBox(width: 16),
                      Icon(
                        Symbols.search,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Search notifications...',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            // Expanded state - full search bar
            Expanded(
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Search notifications...',
                    prefixIcon: const Icon(Symbols.search),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            onPressed: _clearSearch,
                            icon: const Icon(Symbols.clear),
                            tooltip: 'Clear search',
                          ),
                        IconButton(
                          onPressed: _toggleSearch,
                          icon: const Icon(Symbols.close),
                          tooltip: 'Close search',
                        ),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onChanged: (value) {
                    widget.onSearchChanged(value);
                    setState(() {}); // Rebuild to show/hide clear button
                  },
                  onSubmitted: (value) {
                    widget.onSearchChanged(value);
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}