import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditBirthdayScreen extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const title = 'When is your birthday?';
    const subtitle = 'Let us know so we can celebrate together! 🎊';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(height: 24),
          Text(
            title,
            style: ShadTheme.of(context).textTheme.custom['titleEditBirthday'],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * .8,
            ),
            child: Text(
              subtitle,
              style: ShadTheme.of(
                context,
              ).textTheme.custom['subTitleEditBirthday'],
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ShadButton.secondary(
                onPressed: () {},
                child: const Text('Cancel'),
              ),
              const SizedBox(width: 16),
              ShadButton.secondary(onPressed: () {}, child: const Text('Save')),
            ],
          ),
          const SizedBox(height: 24),
          ShadButton(
            onPressed: () {},
            child: Text(
              'Cancel',
              style: ShadTheme.of(context).textTheme.custom['textButtonSubmit'],
            ),
          ),
        ],
      ),
    );
  }
}
