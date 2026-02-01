import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/features/users/presentation/widgets/avatar_widget.dart';
import 'package:locket/features/users/presentation/widgets/body_profile.dart';
import 'package:locket/features/users/presentation/widgets/profile_appbar.dart';
import 'package:locket/shared/presentation/widgets/loading.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileListener = ref.watch(profileProvider);

    return switch (profileListener) {
      AsyncValue(:final value?) => RawScrollbar(
        thumbColor: MyColors.scroll,
        interactive: true,
        trackVisibility: true,
        radius: const Radius.circular(8),
        child: CustomScrollView(
          slivers: <Widget>[
            MultiSliver(
              children: [ProfileAppbar(), AvatarWidget(), BodyProfile()],
            ),
          ],
        ),
      ),
      AsyncValue(error: != null) => const LoadingWidget(),
      AsyncValue() => const LoadingWidget(),
    };
  }
}
