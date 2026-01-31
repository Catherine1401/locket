import 'package:flutter/material.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ItemElementProfile extends StatelessWidget {
  const ItemElementProfile({
    super.key,
    required this.iconUrl,
    required this.title,
    this.color = MyColors.iconItemProfile,
    this.onTap,
  });

  final String iconUrl;
  final String title;
  final Color color;
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
              SizedBox(
                width: 20,
                height: 20,
                child: SvgPicture.asset(
                  iconUrl,
                  width: double.infinity,
                  height: double.infinity,
                  colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
                ),
              ),
              // title
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.custom['textItemProfile']!.copyWith(color: color),
                ),
              ),
              // action
              SvgPicture.asset(
                'assets/icons/forward.svg',
                width: 8,
                height: 16,
                colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
