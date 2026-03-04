import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/friends/injection.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/features/users/presentation/screens/edit_birthday_screen.dart';
import 'package:locket/features/users/presentation/screens/edit_name_screen.dart';
import 'package:locket/features/users/presentation/widgets/badge_body_profile.dart';
import 'package:locket/features/users/presentation/widgets/header_bottomsheet.dart';
import 'package:locket/features/users/presentation/widgets/item_element_profile.dart';

class BodyProfile extends ConsumerWidget {
  const BodyProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).value;
    // Dùng friendsListProvider (cached) thay vì gọi useCase.call() trực tiếp
    // để tránh infinite rebuild loop
    final friendsAsync = ref.watch(friendsListProvider);
    final friendCount = friendsAsync.value?.length ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: MyColors.bgProfile,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // ── Friends ───────────────────────────────────────────
          BadgeBodyProfile(
            iconUrl: 'assets/icons/search.svg',
            title: 'Friends',
            chirdren: [
              ItemElementProfile(
                iconUrl: 'assets/icons/person2.svg',
                title: friendCount == 1 ? '1 Friend' : '$friendCount Friends',
                onTap: () => context.push('/friends'),
              ),
              // Share my link
              ItemElementProfile(
                iconUrl: 'assets/icons/share.svg',
                title: 'Share my link',
                onTap: () {
                  final shareCode = profile?.shareCode;
                  if (shareCode == null || shareCode.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Không tìm thấy share code')),
                    );
                    return;
                  }
                  final link = 'locket://app/add-friend/$shareCode';
                  Clipboard.setData(ClipboardData(text: link));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Đã copy link vào clipboard!'),
                      backgroundColor: MyColors.bgButtonLogin,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                },
              ),
            ],
          ),

          // ── General ───────────────────────────────────────────
          const SizedBox(height: 24),
          BadgeBodyProfile(
            iconUrl: 'assets/icons/person.svg',
            title: 'General',
            chirdren: <Widget>[
              ItemElementProfile(
                iconUrl: 'assets/icons/profile.svg',
                title: 'Edit profile picture',
                onTap: () => ref.read(profileProvider.notifier).updateAvatar(),
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/tag.svg',
                title: 'Edit name',
                onTap: () {
                  showStickyFlexibleBottomSheet(
                    minHeight: 1,
                    initHeight: 1,
                    maxHeight: 1,
                    context: context,
                    headerHeight: 24,
                    isCollapsible: true,
                    isDismissible: true,
                    isModal: true,
                    anchors: [0.0, 1.0],
                    bottomSheetColor: MyColors.bgEditName,
                    bottomSheetBorderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    isSafeArea: true,
                    headerBuilder: (context, offset) {
                      return HeaderBottomsheet();
                    },
                    bodyBuilder: (context, offset) {
                      return SliverChildListDelegate([EditNameScreen()]);
                    },
                  );
                },
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/ballon2.svg',
                title: 'Edit birthday',
                onTap: () {
                  showStickyFlexibleBottomSheet(
                    initHeight: .4,
                    headerHeight: 24,
                    isCollapsible: true,
                    isDismissible: true,
                    isModal: true,
                    anchors: [0.0, .4],
                    bottomSheetColor: MyColors.bgEditName,
                    bottomSheetBorderRadius: BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                    isSafeArea: true,
                    context: context,
                    headerBuilder: (_, _) => HeaderBottomsheet(),
                    bodyBuilder: (_, _) =>
                        SliverChildListDelegate([EditBirthdayScreen()]),
                  );
                },
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/envelope.svg',
                title: 'Change email address',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/music.svg',
                title: 'Unlink music provider',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/question.svg',
                title: 'Get help',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/plus.svg',
                title: 'How to add the widget',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/plane.svg',
                title: 'Share feedback',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/nosign.svg',
                title: 'Blocked',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/dollarsign.svg',
                title: 'Restore purchases',
              ),
            ],
          ),

          // ── About ─────────────────────────────────────────────
          const SizedBox(height: 24),
          BadgeBodyProfile(
            iconUrl: 'assets/icons/heart.svg',
            title: 'About',
            chirdren: <Widget>[
              ItemElementProfile(
                iconUrl: 'assets/icons/tiktok.svg',
                title: 'TikTok',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/instagram.svg',
                title: 'Instagram',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/twitter.svg',
                title: 'Twitter',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/share.svg',
                title: 'Share Locket',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/star.svg',
                title: 'Rate Locket',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/signature.svg',
                title: 'Terms of Service',
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/lock.svg',
                title: 'Privacy policy',
              ),
            ],
          ),

          // ── Danger Zone ───────────────────────────────────────
          const SizedBox(height: 24),
          BadgeBodyProfile(
            iconUrl: 'assets/icons/danger.svg',
            title: 'Danger Zone',
            iconColor: MyColors.danger,
            chirdren: <Widget>[
              ItemElementProfile(
                iconUrl: 'assets/icons/trash.svg',
                title: 'Delete account',
                color: MyColors.danger,
              ),
              ItemElementProfile(
                iconUrl: 'assets/icons/hand.svg',
                title: 'Log out',
                onTap: () async {
                  final profileController = ref.read(profileProvider.notifier);
                  await profileController.logout();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
