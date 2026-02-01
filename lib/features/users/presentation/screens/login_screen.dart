import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/theme/colors.dart';
import 'package:locket/features/users/presentation/riverpod/auth_state_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const logo = "Locket";
    const slogan = "Live pics from your friends on your home screen";
    const messageLogin = "Login with Google";

    return Container(
      color: MyColors.defaultBackground,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(context, logo),
            const SizedBox(height: 24),
            _buildSlogan(context, slogan),
            const SizedBox(height: 40),
            _buildLoginButton(context, ref, messageLogin),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context, String logoText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // logo image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            'assets/images/logo.webp',
            width: 36,
            height: 36,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        // logo text
        Text(logoText, style: ShadTheme.of(context).textTheme.custom['logo']),
      ],
    );
  }

  Widget _buildSlogan(BuildContext context, String sloganText) {
    return Text(
      sloganText,
      style: ShadTheme.of(context).textTheme.custom['slogan'],
      textAlign: TextAlign.center,
    );
  }

  Widget _buildLoginButton(
    BuildContext context,
    WidgetRef ref,
    String messageLogin,
  ) {
    return ShadButton(
      width: 194,
      height: 54,
      // padding: EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      backgroundColor: MyColors.bgButtonLogin,
      decoration: ShadDecoration(
        border: ShadBorder(radius: BorderRadius.circular(50)),
      ),
      child: Text(
        messageLogin,
        style: ShadTheme.of(context).textTheme.custom['messageLogin'],
      ),
      onPressed: () async {
        final authStateController = ref.read(authStateProvider.notifier);
        await authStateController.login();
      },
    );
  }
}
