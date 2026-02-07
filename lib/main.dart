import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:locket/core/injection.dart';
import 'package:locket/core/theme/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

const webClientId = String.fromEnvironment('WEB_CLIENT_ID');
const androidClientId = String.fromEnvironment('ANDROID_CLIENT_ID');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GoogleSignIn.instance.initialize(
    clientId: androidClientId,
    serverClientId: webClientId,
  );
  runApp(ProviderScope(child: const Locket()));
}

class Locket extends ConsumerWidget {
  const Locket({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routerConfig = ref.watch(routerProvider);

    // return switch (routerConfig) {
    //   AsyncValue(:final value?) => ShadApp.router(
    //     debugShowCheckedModeBanner: false,
    //     title: "Locket",
    //     theme: MyTheme.shadThemeData,
    //     routerConfig: value,
    //   ),
    //   AsyncValue(error: != null) => const MaterialApp(
    //     home: Scaffold(body: Center(child: Text("error"))),
    //   ),
    //   AsyncValue() => const MaterialApp(
    //     home: Scaffold(body: Center(child: CircularProgressIndicator())),
    //   ),
    // };

    return ShadApp.router(
      debugShowCheckedModeBanner: false,
      title: "Locket",
      theme: MyTheme.shadThemeData,
      routerConfig: routerConfig,
    );
  }
}

