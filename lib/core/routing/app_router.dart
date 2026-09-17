import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import '../widgets/responsive_content_wrapper.dart';
import '../../features/home/home_screen.dart';
import '../../features/heritage/heritage_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/interactive/interactive_screen.dart';
import '../../features/settings/settings_screen.dart';

final activeTabProvider = StateProvider<int>((ref) => 0);

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const MainNavigationContainer(),
      ),
    ],
  );
});

class MainNavigationContainer extends ConsumerStatefulWidget {
  const MainNavigationContainer({super.key});

  @override
  ConsumerState<MainNavigationContainer> createState() => _MainNavigationContainerState();
}

class _MainNavigationContainerState extends ConsumerState<MainNavigationContainer> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  void _onTabSelected(int index, int currentIndex) {
    if (currentIndex == index) {
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
    } else {
      ref.read(activeTabProvider.notifier).state = index;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;
    final isLandscape = orientation == Orientation.landscape;
    final isLargeScreen = size.width > 800;
    final showRail = isLandscape || isLargeScreen;
    final currentIndex = ref.watch(activeTabProvider);

    final List<Map<String, dynamic>> tabs = [
      {
        'title': 'navigation.home'.tr(),
        'icon': Icons.home_outlined,
        'selectedIcon': Icons.home_rounded,
        'widget': const HomeScreen(),
      },
      {
        'title': 'navigation.heritage'.tr(),
        'icon': Icons.museum_outlined,
        'selectedIcon': Icons.museum_rounded,
        'widget': const HeritageScreen(),
      },
      {
        'title': 'navigation.library'.tr(),
        'icon': Icons.collections_bookmark_outlined,
        'selectedIcon': Icons.collections_bookmark_rounded,
        'widget': const LibraryScreen(),
      },
      {
        'title': 'navigation.interactive'.tr(),
        'icon': Icons.interests_outlined,
        'selectedIcon': Icons.interests_rounded,
        'widget': const InteractiveScreen(),
      },
      {
        'title': 'navigation.settings'.tr(),
        'icon': Icons.settings_outlined,
        'selectedIcon': Icons.settings_rounded,
        'widget': const SettingsScreen(),
      },
    ];

    final tabNavigators = List.generate(tabs.length, (index) {
      return Navigator(
        key: _navigatorKeys[index],
        onGenerateRoute: (settings) => MaterialPageRoute(
          settings: settings,
          builder: (context) => tabs[index]['widget'] as Widget,
        ),
      );
    });

    final currentNav = _navigatorKeys[currentIndex].currentState;
    final canCurrentNavPop = currentNav?.canPop() ?? false;

    final bodyContent = PopScope(
      canPop: currentIndex == 0 && !canCurrentNavPop,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final nav = _navigatorKeys[currentIndex].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        } else if (currentIndex != 0) {
          ref.read(activeTabProvider.notifier).state = 0;
        }
      },
      child: IndexedStack(
        index: currentIndex,
        children: tabNavigators,
      ),
    );

    if (showRail) {
      return Scaffold(
        body: Row(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: currentIndex,
                        onDestinationSelected: (index) => _onTabSelected(index, currentIndex),
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: theme.colorScheme.surfaceContainer,
                        indicatorColor: theme.colorScheme.primaryContainer,
                        unselectedIconTheme: IconThemeData(color: theme.colorScheme.onSurfaceVariant),
                        selectedIconTheme: IconThemeData(color: theme.colorScheme.onPrimaryContainer),
                        selectedLabelTextStyle: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedLabelTextStyle: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        destinations: tabs.map((tab) {
                          return NavigationRailDestination(
                            icon: Icon(tab['icon']),
                            selectedIcon: Icon(tab['selectedIcon']),
                            label: Text(tab['title']),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                );
              },
            ),
            const VerticalDivider(thickness: 1, width: 1),
            Expanded(
              child: ResponsiveContentWrapper(
                child: bodyContent,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onTabSelected(index, currentIndex),
        type: BottomNavigationBarType.fixed,
        backgroundColor: theme.colorScheme.surfaceContainer,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurfaceVariant,
        selectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 12, fontWeight: FontWeight.bold),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(fontSize: 12),
        items: tabs.map((tab) {
          return BottomNavigationBarItem(
            icon: Icon(tab['icon']),
            activeIcon: Icon(tab['selectedIcon']),
            label: tab['title'],
          );
        }).toList(),
      ),
    );
  }
}
