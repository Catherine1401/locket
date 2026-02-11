import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/profile_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class EditNameScreen extends HookConsumerWidget {
  const EditNameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileListener = ref.watch(profileProvider);
    final isLoading = profileListener is AsyncLoading;

    final nameFocusNode = useFocusNode();
    final formKey = useMemoized(() => GlobalKey<ShadFormState>());

    const placeholder = 'Enter your name';
    const title = 'Change your name';
    final submit = isLoading ? 'Saving...' : 'Save';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      // decoration: BoxDecoration(
      //   color: MyColors.bgEditName,
      // ),
      child: Column(
        children: <Widget>[
          // header
          const SizedBox(height: 112),
          Text(
            title,
            style: ShadTheme.of(context).textTheme.custom['titleEditName'],
          ),
          const SizedBox(height: 32),
          // form
          ShadForm(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                // text field
                ShadInputFormField(
                  focusNode: nameFocusNode,
                  id: 'name',
                  placeholder: const Text(placeholder),
                  initialValue: profileListener.value?.displayName,
                  autofocus: true,
                  style: ShadTheme.of(
                    context,
                  ).textTheme.custom['contentEditName'],
                  // autofocus: true,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 16,
                  ),
                  decoration: ShadDecoration(
                    color: MyColors.bgTextField,
                    border: ShadBorder.all(
                      width: 0,
                      radius: BorderRadius.circular(16),
                    ),
                    secondaryBorder: ShadBorder.all(
                      width: 0,
                      radius: BorderRadius.circular(16),
                    ),
                    focusedBorder: ShadBorder.all(
                      width: 0,
                      radius: BorderRadius.circular(16),
                    ),
                    secondaryFocusedBorder: ShadBorder.all(
                      width: 0,
                      radius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressedOutside: (_) {
                    nameFocusNode.unfocus();
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.trim().length > 20) {
                      return 'Name cannot be longer than 20 characters';
                    }
                    if (value.trim().length < 3) {
                      return 'Name cannot be shorter than 3 characters';
                    }
                    return null;
                  },
                ),
                // submit button
                const SizedBox(height: 180),
                ShadButton(
                  expands: true,
                  height: 48,
                  backgroundColor: MyColors.bgButtonLogin,
                  decoration: ShadDecoration(
                    border: ShadBorder.all(radius: BorderRadius.circular(16)),
                    secondaryBorder: ShadBorder.none,
                  ),
                  onPressed: () async {
                    if (formKey.currentState!.saveAndValidate()) {
                      print('save and validate');
                      final profileController = ref.read(
                        profileProvider.notifier,
                      );
                      final name =
                          (formKey.currentState!.value['name'] as String)
                              .trim();
                      await profileController.updateDisplayName(name);
                      context.pop();
                    } else {
                      print('not save and validate');
                    }
                  },
                  leading: isLoading ? const CircularProgressIndicator() : null,
                  child: Text(
                    submit,
                    style: ShadTheme.of(
                      context,
                    ).textTheme.custom['textButtonSubmit'],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
