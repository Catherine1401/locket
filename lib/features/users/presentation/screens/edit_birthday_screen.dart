import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const _months = [
  'January', 'February', 'March', 'April',
  'May', 'June', 'July', 'August',
  'September', 'October', 'November', 'December',
];

int _daysInMonth(int month) {
  const days = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
  return days[month - 1];
}

class EditBirthdayScreen extends HookConsumerWidget {
  const EditBirthdayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final isLoading = profileState is AsyncLoading;

    // Parse existing birthday
    final existingBirthday = profileState.value?.birthday;
    int? initialMonth;
    int? initialDay;
    if (existingBirthday != null && existingBirthday.isNotEmpty) {
      final parts = existingBirthday.split('-');
      if (parts.length >= 3) {
        initialMonth = int.tryParse(parts[1]);
        initialDay = int.tryParse(parts[2]);
      }
    }

    final selectedMonth = useState<int?>(initialMonth);
    final selectedDay = useState<int?>(initialDay);

    final canSave = selectedMonth.value != null && selectedDay.value != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),

          // Title
          const Text(
            'When is your birthday?',
            style: TextStyle(
              color: MyColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Subtitle
          const Text(
            "Let us know so we can celebrate together! 🎉",
            style: TextStyle(
              color: MyColors.textSubtitleBirthday,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),

          // Month + Day picker buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _PickerButton(
                label: selectedMonth.value != null
                    ? _months[selectedMonth.value! - 1]
                    : 'Month',
                isSelected: selectedMonth.value != null,
                onTap: () => _showDropdown(
                  context,
                  items: _months,
                  selectedIndex: selectedMonth.value != null
                      ? selectedMonth.value! - 1
                      : null,
                  onSelect: (i) => selectedMonth.value = i + 1,
                ),
              ),
              const SizedBox(width: 12),
              _PickerButton(
                label: selectedDay.value?.toString() ?? 'Day',
                isSelected: selectedDay.value != null,
                onTap: () => _showDropdown(
                  context,
                  items: List.generate(
                    _daysInMonth(selectedMonth.value ?? 1),
                    (i) => '${i + 1}',
                  ),
                  selectedIndex: selectedDay.value != null
                      ? selectedDay.value! - 1
                      : null,
                  onSelect: (i) => selectedDay.value = i + 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

          // Save button
          ShadButton(
            expands: true,
            height: 52,
            backgroundColor: canSave
                ? MyColors.bgButtonLogin
                : MyColors.bgSaveButtonDisabled,
            decoration: ShadDecoration(
              border: ShadBorder.all(radius: BorderRadius.circular(26)),
              secondaryBorder: ShadBorder.none,
            ),
            onPressed: (!canSave || isLoading)
                ? null
                : () async {
                    final mm = selectedMonth.value!.toString().padLeft(2, '0');
                    final dd = selectedDay.value!.toString().padLeft(2, '0');
                    await ref
                        .read(profileProvider.notifier)
                        .updateBirthday('2000-$mm-$dd');
                    if (context.mounted) Navigator.of(context).pop();
                  },
            leading: isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
            child: Text(
              isLoading ? 'Saving...' : 'Save',
              style: TextStyle(
                color: canSave
                    ? MyColors.textButtonSubmit
                    : MyColors.textSaveButtonDisabled,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _showDropdown(
    BuildContext context, {
    required List<String> items,
    required int? selectedIndex,
    required ValueChanged<int> onSelect,
  }) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _DropdownDialog(
        items: items,
        selectedIndex: selectedIndex,
        onSelect: onSelect,
      ),
    );
  }
}

// ─── Picker Button ────────────────────────────────────────────────────────────

class _PickerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PickerButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 13),
        decoration: BoxDecoration(
          color: isSelected
              ? MyColors.bgPickerButtonSelected
              : MyColors.bgPickerButtonDisabled,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? MyColors.white
                : MyColors.textPickerButtonDisabled,
            fontSize: 15,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─── Dropdown Dialog ──────────────────────────────────────────────────────────

class _DropdownDialog extends HookWidget {
  final List<String> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelect;

  const _DropdownDialog({
    required this.items,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final controller = useScrollController();

    useEffect(() {
      if (selectedIndex != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final offset = selectedIndex! * 48.0;
          if (controller.hasClients) {
            controller.jumpTo(
              offset.clamp(0.0, controller.position.maxScrollExtent),
            );
          }
        });
      }
      return null;
    }, []);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 340, maxWidth: 280),
        decoration: BoxDecoration(
          color: MyColors.bgDropdownBirthday,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.builder(
            controller: controller,
            itemCount: items.length,
            itemExtent: 48,
            itemBuilder: (_, i) {
              final isSelected = selectedIndex == i;
              return GestureDetector(
                onTap: () {
                  onSelect(i);
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: isSelected
                      ? MyColors.bgDropdownItemSelected
                      : Colors.transparent,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    items[i],
                    style: TextStyle(
                      color: isSelected ? MyColors.white : MyColors.textSubtitleBirthday,
                      fontSize: 16,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
