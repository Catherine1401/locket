import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:locket/core/router/go_router.dart';
import 'package:locket/core/theme/theme.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

void main() {
  runApp(ProviderScope(child: const Locket()));
}

class Locket extends StatelessWidget {
  const Locket({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadApp.router(
      debugShowCheckedModeBanner: false,
      title: "Locket", 
      theme: MyTheme.shadThemeData,
      routerConfig: RouterCfig.routerConfig,
    );
  }
}