import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  static DevToolsRouterDelegate of(BuildContext context) =>
      Router.of(context).routerDelegate as DevToolsRouterDelegate;

  @override
  DevToolsRouteConfiguration get currentConfiguration {
    if (routes.isEmpty) {
      return null;
    }
    return routes.last;
  }

  @override
  Widget build(BuildContext context) {
    final routeConfig = routes.last;
    final screen = routeConfig.screen;
    final args = routeConfig.args ?? {};

    print('RouterDelegate is building $screen');

    return Navigator(
      key: navigatorKey,
      pages: [
        // Dummy page to ensure there's always > 1
        MaterialPage(child: Text('test root page...')),
        getPage(context, screen, args),
      ],
      // why isn't this called?
      onPopPage: (_, __) => popPage(),
    );
  }

  bool popPage() {
    if (routes.length <= 1) {
      print('skipping popRoute');
      return false;
    }
    print('popping ${routes.last.screen}');
    routes.removeLast();
    notifyListeners();
    return true;
  }

  void pushScreenIfNotCurrent(String screen, [Map<String, String> updateArgs]) {
    final screenChanged = screen != currentConfiguration.screen;
    final argsChanged = !mapEquals(
      {...currentConfiguration.args, ...?updateArgs},
      currentConfiguration.args,
    );
    if (!screenChanged && !argsChanged) {
      return;
    }

    print('pushing $screen');
    routes.add(DevToolsRouteConfiguration(
        screen, {...currentConfiguration.args, ...?updateArgs}));
    // Needs to notify the router that the state has changed.
    notifyListeners();
  }

  @override
  Future<void> setNewRoutePath(DevToolsRouteConfiguration configuration) {
    print('setting new route path ${configuration?.screen}');
    routes.add(configuration);
    return SynchronousFuture<void>(null);
  }

  void updateArgsIfNotCurrent(Map<String, String> updateArgs) {
    final argsChanged = !mapEquals(
      {...currentConfiguration.args, ...?updateArgs},
      currentConfiguration.args,
    );
    if (!argsChanged) {
      return;
    }

    print('updating args on ${currentConfiguration.screen}');
    routes.add(DevToolsRouteConfiguration(
      currentConfiguration.screen,
      {...currentConfiguration.args, ...updateArgs},
    ));
    // Needs to notify the router that the state has changed.
    notifyListeners();
  }
}
