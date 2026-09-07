import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'core/localization/fallback_localizations_delegate.dart';
import 'core/routing/app_router.dart';
import 'core/services/memory_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';

class AppHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..userAgent = 'NiasHeritage/1.0 (https://github.com/sslaia/niasheritage; contact@example.com)';
  }
}

void main() async {
  HttpOverrides.global = AppHttpOverrides();
  WidgetsFlutterBinding.ensureInitialized();
  MemoryManager.instance.initialize();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('id'), Locale('nia')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: NiasHeritageApp()),
    ),
  );
}

class NiasHeritageApp extends ConsumerWidget {
  const NiasHeritageApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => 'app_title'.tr(),
      localizationsDelegates: [
        ...context.localizationDelegates,
        const FallbackMaterialLocalizationsDelegate(),
        const FallbackCupertinoLocalizationsDelegate(),
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

