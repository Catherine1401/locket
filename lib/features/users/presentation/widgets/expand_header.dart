import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/shared/presentation/widgets/error.dart';
import 'package:locket/shared/presentation/widgets/loading.dart';

class ExpandHeader extends ConsumerWidget {
  const ExpandHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return switch (profile) {
      AsyncValue(:final value?) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [CircleAvatar(
          backgroundImage: CachedNetworkImageProvider(value.avatarUrl),
        )],
      ),
      AsyncValue(error: != null) => const MyErrorWidget(),
      AsyncValue() => const LoadingWidget(),
    };

    // return Column(
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     CircleAvatar(
    //       backgroundImage: ,
    //     )
    //   ],
    // );
  }
}
