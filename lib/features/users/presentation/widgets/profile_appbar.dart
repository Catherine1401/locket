import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/shared/presentation/widgets/error.dart';
import 'package:locket/shared/presentation/widgets/loading.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfileAppbar extends ConsumerWidget {
  const ProfileAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    return switch (profile) {
      AsyncValue(:final value?) => SliverLayoutBuilder(
        builder: (_, constrains) {
          print('scroll offset: ${constrains.scrollOffset}');
          final isHide = constrains.scrollOffset > 240;
          return SliverAppBar(
            backgroundColor: MyColors.bgProfile,
            automaticallyImplyLeading: false,
            surfaceTintColor: Colors.transparent,
            pinned: true,
            collapsedHeight: kToolbarHeight,
            expandedHeight: kToolbarHeight,
            centerTitle: true,
            title: !isHide
                ? const SizedBox()
                : _buildTitle(context, value.avatarUrl, value.displayName),
          );
        },
      ),
      AsyncValue(error: != null) => const MyErrorWidget(),
      AsyncValue() => const LoadingWidget(),
    };
  }

  Widget _buildTitle(
    BuildContext context,
    String avatarUrl,
    String displayName,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        ClipOval(
          child: CachedNetworkImage(
            imageUrl: avatarUrl,
            fit: BoxFit.contain,
            width: 32,
            height: 32,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          displayName,
          style: ShadTheme.of(context).textTheme.custom['nameAppbar'],
        ),
      ],
    );
  }
}
