import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class DevToolsRouteConfiguration {
  final String screen;
  final Map<String, String> args;
  DevToolsRouteConfiguration(this.screen, this.args);

  RouteInformation toRouteInformation() {
    final path = '/${screen ?? ''}';
    final params = (args?.length ?? 0) != 0 ? args : null;
    return RouteInformation(
        location: Uri(path: path, queryParameters: params).toString());
  }

  static DevToolsRouteConfiguration fromRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);
    return DevToolsRouteConfiguration(
        uri.path.substring(1), uri.queryParameters);
  }
}

class DevToolsRouteInformationParser
    extends RouteInformationParser<DevToolsRouteConfiguration> {
  @override
  Future<DevToolsRouteConfiguration> parseRouteInformation(
      RouteInformation routeInformation) {
    print('parsing route: ${routeInformation.location}');
    return SynchronousFuture<DevToolsRouteConfiguration>(
        DevToolsRouteConfiguration.fromRouteInformation(routeInformation));
  }

  @override
  RouteInformation restoreRouteInformation(
      DevToolsRouteConfiguration configuration) {
    print('restoring route: ${configuration?.screen} : ${configuration?.args}');
    return configuration.toRouteInformation();
  }
}

class DevToolsRouterDelegate extends RouterDelegate<DevToolsRouteConfiguration>
    with
        ChangeNotifier,
        PopNavigatorRouterDelegateMixin<DevToolsRouteConfiguration> {
  final GlobalKey<NavigatorState> navigatorKey;
  final Page Function(BuildContext, String, Map<String, String>) getPage;
  final routes = ListQueue<DevToolsRouteConfiguration>();

  DevToolsRouterDelegate(this.getPage)
      : navigatorKey = GlobalKey<NavigatorState>();

  @override
  DevToolsRouteConfiguration get currentConfiguration {
    if (routes.isEmpty) {
      print('returning null as current config');
      return null;
    }
    print('returning "${routes.last}" as current config');
    return routes.last;
  }

  @override
  Widget build(BuildContext context) {
    final routeConfig = routes.last;
    final screen = routeConfig.screen;
    final args = routeConfig.args ?? {};

    print('RouterDelegate is building! $screen / $args');

    return Navigator(
      key: navigatorKey,
      pages: [getPage(context, screen, args)],
      onPopPage: (_, __) => _popPage(),
    );
  }

  bool _popPage() {
    if (routes.length <= 1) {
      print('skipping popRoute');
      return false;
    }
    print('removing last route');
    routes.removeLast();
    notifyListeners();
    return true;
  }

  void pushScreen(String screen, [Map<String, String> args]) {
    print('pushing new screen $screen');
    routes.add(DevToolsRouteConfiguration(
        screen, {...currentConfiguration.args, ...?args}));
    // Needs to notify the router that the state has changed.
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(DevToolsRouteConfiguration configuration) {
    print(
        'setting new route path "${configuration?.screen}" / ${configuration?.args}');
    routes.add(configuration);
    return SynchronousFuture<void>(null);
  }

  void updateArgs(Map<String, String> replacementArgs) {
    print('pushing screen with replaced args $replacementArgs');
    routes.add(DevToolsRouteConfiguration(
      currentConfiguration.screen,
      {...currentConfiguration.args, ...replacementArgs},
    ));
    // Needs to notify the router that the state has changed.
    notifyListeners();
  }
}
