import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:fieldforce/features/notifications/model/notification_filter.dart';
import 'package:fieldforce/features/notifications/model/notification_enums.dart';

/// Bottom sheet for filtering notifications
class NotificationFilterSheet extends StatefulWidget {
  final NotificationFilter currentFilter;
  final Function(NotificationFilter) onFilterChanged;

  const NotificationFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onFilterChanged,
  });

  @override
  State<NotificationFilterSheet> createState() => _NotificationFilterSheetState();
}

class _NotificationFilterSheetState extends State<NotificationFilterSheet> {
  late NotificationFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  void _updateFilter(NotificationFilter newFilter) {
    setState(() {
      _filter = newFilter;
    });
  }

  void _applyFilter() {
    widget.onFilterChanged(_filter);
    Navigator.pop(context);
  }

  void _clearFilter() {
    _updateFilter(const NotificationFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Symbols.filter_alt),
                const SizedBox(width: 12),
                Text(
                  'Filter Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Spacer(),
                if (_filter.hasActiveFilters)
                  TextButton(
                    onPressed: _clearFilter,
                    child: const Text('Clear All'),
                  ),
              ],
            ),
          ),

          const Divider(),

          // Filter content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick filters
                  _buildQuickFilters(),
                  const SizedBox(height: 24),

                  // Categories
                  _buildCategoryFilter(),
                  const SizedBox(height: 24),

                  // Status
                  _buildStatusFilter(),
                  const SizedBox(height: 24),

                  // Priority
                  _buildPriorityFilter(),
                  const SizedBox(height: 24),

                  // Date range
                  _buildDateRangeFilter(),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilter,
                    child: Text(
                      _filter.hasActiveFilters 
                          ? 'Apply (${_filter.activeFilterCount})'
                          : 'Apply',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickFilterChip(
              'Unread Only',
              _filter.onlyUnread,
              () => _updateFilter(_filter.copyWith(onlyUnread: !_filter.onlyUnread)),
            ),
            _buildQuickFilterChip(
              'High Priority',
              _filter.onlyHighPriority,
              () => _updateFilter(_filter.copyWith(onlyHighPriority: !_filter.onlyHighPriority)),
            ),
            _buildQuickFilterChip(
              'Today',
              _isToday(_filter),
              () => _updateFilter(_filter.todayOnly()),
            ),
            _buildQuickFilterChip(
              'This Week',
              _isThisWeek(_filter),
              () => _updateFilter(_filter.thisWeekOnly()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
    );
  }

  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categories',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationCategory.values.map((category) {
            final isSelected = _filter.categories?.contains(category) ?? false;
            return FilterChip(
              label: Text(category.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final categories = List<NotificationCategory>.from(_filter.categories ?? []);
                if (selected) {
                  categories.add(category);
                } else {
                  categories.remove(category);
                }
                _updateFilter(_filter.copyWith(
                  categories: categories.isEmpty ? null : categories,
                ));
              },
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            NotificationStatus.unread,
            NotificationStatus.read,
            NotificationStatus.archived,
          ].map((status) {
            final isSelected = _filter.statuses?.contains(status) ?? false;
            return FilterChip(
              label: Text(status.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final statuses = List<NotificationStatus>.from(_filter.statuses ?? []);
                if (selected) {
                  statuses.add(status);
                } else {
                  statuses.remove(status);
                }
                _updateFilter(_filter.copyWith(
                  statuses: statuses.isEmpty ? null : statuses,
                ));
              },
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: NotificationPriority.values.map((priority) {
            final isSelected = _filter.priorities?.contains(priority) ?? false;
            return FilterChip(
              label: Text(priority.displayName),
              selected: isSelected,
              onSelected: (selected) {
                final priorities = List<NotificationPriority>.from(_filter.priorities ?? []);
                if (selected) {
                  priorities.add(priority);
                } else {
                  priorities.remove(priority);
                }
                _updateFilter(_filter.copyWith(
                  priorities: priorities.isEmpty ? null : priorities,
                ));
              },
              showCheckmark: false,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectStartDate(),
                icon: const Icon(Symbols.calendar_today),
                label: Text(
                  _filter.startDate != null
                      ? _formatDate(_filter.startDate!)
                      : 'Start Date',
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _selectEndDate(),
                icon: const Icon(Symbols.calendar_today),
                label: Text(
                  _filter.endDate != null
                      ? _formatDate(_filter.endDate!)
                      : 'End Date',
                ),
              ),
            ),
          ],
        ),
        if (_filter.startDate != null || _filter.endDate != null) ...[
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: () => _updateFilter(_filter.copyWith(
              startDate: null,
              endDate: null,
            )),
            icon: const Icon(Symbols.clear),
            label: const Text('Clear Date Range'),
          ),
        ],
      ],
    );
  }

  Future<void> _selectStartDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filter.startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: _filter.endDate ?? DateTime.now(),
    );
    if (date != null) {
      _updateFilter(_filter.copyWith(startDate: date));
    }
  }

  Future<void> _selectEndDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filter.endDate ?? DateTime.now(),
      firstDate: _filter.startDate ?? DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      _updateFilter(_filter.copyWith(endDate: date));
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  bool _isToday(NotificationFilter filter) {
    if (filter.startDate == null || filter.endDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return filter.startDate!.isAtSameMomentAs(today) &&
           filter.endDate!.isAtSameMomentAs(endOfDay);
  }

  bool _isThisWeek(NotificationFilter filter) {
    if (filter.startDate == null || filter.endDate == null) return false;
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return filter.startDate!.isAtSameMomentAs(startOfDay) &&
           filter.endDate!.day == now.day;
  }
}