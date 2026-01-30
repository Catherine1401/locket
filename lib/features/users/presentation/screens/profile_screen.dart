import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/presentation/widgets/avatar_widget.dart';
import 'package:locket/features/users/presentation/widgets/profile_appbar.dart';
import 'package:sliver_tools/sliver_tools.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: <Widget>[
        MultiSliver(
          children: [ProfileAppbar(), AvatarWidget(), SizedBox(height: 1000)],
        ),
      ],
    );
  }
}
