import 'package:fieldforce/apis/industry_api.dart';
import 'package:fieldforce/features/company/model/industry_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final getIndustriesProvider = FutureProvider<List<IndustryModel>>((ref) async {
  final industryAPI = ref.watch(industryAPIProvider);
  final res = await industryAPI.getIndustries();
  return res.fold((l) => <IndustryModel>[], (r) => r);
});

class IndustryFilterButtons extends ConsumerWidget {
  final Function(String?) onIndustrySelected;

  const IndustryFilterButtons({super.key, required this.onIndustrySelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final industriesAsyncValue = ref.watch(getIndustriesProvider);
    return industriesAsyncValue.when(
      data: (industries) =>
          IndustryFilterRow(onIndustrySelected: onIndustrySelected),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }
}

class IndustryFilterRow extends ConsumerStatefulWidget {
  final Function(String?) onIndustrySelected;

  const IndustryFilterRow({super.key, required this.onIndustrySelected});

  @override
  ConsumerState<IndustryFilterRow> createState() => _IndustryFilterRowState();
}

class _IndustryFilterRowState extends ConsumerState<IndustryFilterRow> {
  String? selectedIndustryId;
  bool showAll = false;

  @override
  Widget build(BuildContext context) {
    final industries = ref.watch(getIndustriesProvider).asData?.value ?? [];
    final displayedIndustries =
        showAll ? industries : industries.take(4).toList();

    return Column(
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          alignment: WrapAlignment.center,
          children: [
            ...displayedIndustries.map((industry) {
              return FilterChip(
                label: Text(industry.name),
                selected: selectedIndustryId == industry.id,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      selectedIndustryId = industry.id;
                    } else {
                      selectedIndustryId = null;
                    }
                    widget.onIndustrySelected(selectedIndustryId);
                  });
                },
              );
            }),
            if (industries.length > 4)
              FilterChip(
                label: Text(showAll ? 'Less' : 'More'),
                onSelected: (selected) {
                  setState(() {
                    showAll = !showAll;
                  });
                },
              ),
          ],
        ),
      ],
    );
  }
}
