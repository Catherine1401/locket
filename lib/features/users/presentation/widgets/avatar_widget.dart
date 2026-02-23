import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/shared/presentation/widgets/error.dart';
import 'package:locket/shared/presentation/widgets/loading.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class AvatarWidget extends ConsumerWidget {
  const AvatarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);

    return switch (profile) {
      AsyncValue(:final value?) => _buildLayout(
        context,
        ref,
        value.avatarUrl,
        value.displayName,
      ),
      AsyncValue(error: != null) => const MyErrorWidget(),
      AsyncValue() => const LoadingWidget(),
    };
  }

  Widget _buildLayout(
    BuildContext context,
    WidgetRef ref,
    String avatarUrl,
    String displayName,
  ) {
    return Container(
      color: MyColors.bgProfile,
      padding: const EdgeInsets.only(top: 20),
      alignment: Alignment.topCenter,
      width: double.infinity,
      height: 220,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildAvatar(avatarUrl, ref),
          const SizedBox(height: 12),
          _buildName(context, displayName),
        ],
      ),
    );
  }

  Widget _buildAvatar(String avatarUrl, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(profileProvider.notifier).updateAvatar(),
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(width: 4, color: MyColors.bgButtonLogin),
              ),
              child: ClipOval(
                child: CachedNetworkImage(
                  imageUrl: avatarUrl,
                  fadeOutDuration: const Duration(milliseconds: 500),
                  fit: BoxFit.cover,
                  placeholder: (_, _) => const CircularProgressIndicator(),
                  errorWidget: (_, _, _) => const Icon(Icons.error),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: MyColors.bgButtonLogin,
                  shape: BoxShape.circle,
                  border: Border.all(width: 2, color: MyColors.bgProfile),
                ),
                child: const Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildName(BuildContext context, String displayName) {
    final maxWidth = MediaQuery.sizeOf(context).width * .5;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Text(
        displayName,
        style: ShadTheme.of(context).textTheme.custom['name'],
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textWidthBasis: TextWidthBasis.longestLine,
      ),
    );
  }
}
