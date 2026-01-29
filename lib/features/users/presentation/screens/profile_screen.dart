import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: ShadButton(
      onPressed: () async {
        final clm = await ref.read(profileProvider.notifier).logout();
      },
        child: Text("sign out"),
      ),
    );
  }
}


