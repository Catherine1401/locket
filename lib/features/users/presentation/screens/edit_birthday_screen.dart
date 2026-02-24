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

    // Parse existing birthday if any
    final existingBirthday = profileState.value?.birthday;
    int initialMonth = 1;
    int initialDay = 1;
    if (existingBirthday != null && existingBirthday.isNotEmpty) {
      final parts = existingBirthday.split('-');
      if (parts.length >= 3) {
        initialMonth = int.tryParse(parts[1]) ?? 1;
        initialDay = int.tryParse(parts[2]) ?? 1;
      }
    }

    // 0 = Month tab, 1 = Day tab
    final activeTab = useState(0);
    final selectedMonth = useState(initialMonth); // 1–12
    final selectedDay = useState(initialDay);     // 1–31

    final monthController = useScrollController();
    final dayController = useScrollController();

    final itemHeight = 48.0;

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final mOffset = (selectedMonth.value - 1) * itemHeight;
        final dOffset = (selectedDay.value - 1) * itemHeight;
        if (monthController.hasClients) {
          monthController.jumpTo(mOffset);
        }
        if (dayController.hasClients) {
          dayController.jumpTo(dOffset);
        }
      });
      return null;
    }, []);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Picker container
        Container(
          height: 340,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: Row(
                  children: [
                    Text(
                      activeTab.value == 0 ? 'Month' : 'Day',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFF3A3A3A)),

              // Scrollable list
              Expanded(
                child: activeTab.value == 0
                    ? _buildMonthPicker(
                        monthController,
                        selectedMonth,
                        itemHeight,
                      )
                    : _buildDayPicker(
                        dayController,
                        selectedDay,
                        selectedMonth.value,
                        itemHeight,
                      ),
              ),

              const Divider(height: 1, color: Color(0xFF3A3A3A)),

              // Tab switcher
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTab('Month', activeTab.value == 0, () {
                      activeTab.value = 0;
                    }),
                    const SizedBox(width: 12),
                    _buildTab('Day', activeTab.value == 1, () {
                      activeTab.value = 1;
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Save button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: ShadButton(
            expands: true,
            height: 48,
            backgroundColor: MyColors.bgButtonLogin,
            decoration: ShadDecoration(
              border: ShadBorder.all(radius: BorderRadius.circular(16)),
              secondaryBorder: ShadBorder.none,
            ),
            onPressed: isLoading
                ? null
                : () async {
                    // Format: YYYY-MM-DD (dùng year 2000 làm placeholder)
                    final mm = selectedMonth.value.toString().padLeft(2, '0');
                    final dd = selectedDay.value.toString().padLeft(2, '0');
                    final birthday = '2000-$mm-$dd';
                    await ref
                        .read(profileProvider.notifier)
                        .updateBirthday(birthday);
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
              style: ShadTheme.of(
                context,
              ).textTheme.custom['textButtonSubmit'],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMonthPicker(
    ScrollController controller,
    ValueNotifier<int> selected,
    double itemHeight,
  ) {
    return ListView.builder(
      controller: controller,
      itemCount: _months.length,
      itemExtent: itemHeight,
      itemBuilder: (_, i) {
        final month = i + 1;
        final isSelected = selected.value == month;
        return GestureDetector(
          onTap: () => selected.value = month,
          child: Container(
            color: isSelected
                ? const Color(0xFF3D3D3D)
                : Colors.transparent,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              _months[i],
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDayPicker(
    ScrollController controller,
    ValueNotifier<int> selected,
    int month,
    double itemHeight,
  ) {
    final total = _daysInMonth(month);
    // Clamp if switching month reduces days
    if (selected.value > total) selected.value = total;

    return ListView.builder(
      controller: controller,
      itemCount: total,
      itemExtent: itemHeight,
      itemBuilder: (_, i) {
        final day = i + 1;
        final isSelected = selected.value == day;
        return GestureDetector(
          onTap: () => selected.value = day,
          child: Container(
            color: isSelected
                ? const Color(0xFF3D3D3D)
                : Colors.transparent,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF4A4A4A)
              : const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
