import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ItemElementProfile extends StatelessWidget {
  const ItemElementProfile({
    super.key,
    required this.iconUrl,
    required this.title,
    this.onTap,
  });

  final String iconUrl;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      // borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.hardEdge,
      child: Material(
        color: Colors.transparent,
        child: InkResponse(
          onTap: onTap ?? () => {},
          containedInkWell: true,
          child: Row(
            children: <Widget>[
              // icon
              Container(
                width: 40,
                height: 40,
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(
                  maxWidth: 38,
                  maxHeight: 38,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: MyColors.bgIconItemProfile,
                ),
                child: SvgPicture.asset(
                  iconUrl,
                  width: double.infinity,
                  height: double.infinity,
                  colorFilter: ColorFilter.mode(
                    MyColors.iconItemProfile,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              // title
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.custom['textItemProfile'],
                ),
              ),
              // action
              SvgPicture.asset(
                'assets/icons/forward.svg',
                width: 8,
                height: 16,
                colorFilter: ColorFilter.mode(
                  MyColors.iconItemProfile,
                  BlendMode.srcIn,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
