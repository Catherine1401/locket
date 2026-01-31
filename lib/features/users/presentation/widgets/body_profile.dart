import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:locket/features/users/presentation/screens/edit_name_screen.dart';
import 'package:locket/features/users/presentation/widgets/badge_body_profile.dart';
import 'package:locket/features/users/presentation/widgets/header_bottomsheet.dart';
import 'package:locket/features/users/presentation/widgets/item_element_profile.dart';

class BodyProfile extends ConsumerWidget {
  const BodyProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: MyColors.bgProfile,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          // friends
          BadgeBodyProfile(
            iconUrl: 'assets/icons/search.svg',
            title: 'Friends',
            chirdren: [
              ItemElementProfile(
                iconUrl: 'assets/icons/person2.svg',
                title: '1 Friend',
              ),
            ],
          ),

          // general
          const SizedBox(height: 24),
          BadgeBodyProfile(
            iconUrl: 'assets/icons/person.svg',
            title: 'General',
            chirdren: <Widget>[
              ItemElementProfile(
                iconUrl: 'assets/icons/profile.svg',
                title: 'Edit profile picture',
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

          // about
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

          // danger zone
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
