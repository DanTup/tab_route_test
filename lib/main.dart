import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tab_route_test/routing.dart';
import 'package:tab_route_test/scaffold.dart';

void main() {
  runApp(DevToolsApp());
}

const homeRoute = '/';

const otherRoute = '/other';

typedef UrlParametersBuilder = Widget Function(
  BuildContext,
  String,
  Map<String, String>,
);

/// Top-level configuration for the app.
@immutable
class DevToolsApp extends StatefulWidget {
  const DevToolsApp();

  @override
  State<DevToolsApp> createState() => DevToolsAppState();

  static DevToolsAppState of(BuildContext context) {
    return context.findAncestorStateOfType<DevToolsAppState>();
  }
}

class DevToolsAppState extends State<DevToolsApp> {
  Map<String, UrlParametersBuilder> _routes;

  /// The routes that the app exposes.
  Map<String, UrlParametersBuilder> get routes {
    return _routes ??= {
      homeRoute: (context, page, params) {
        print(params);
        if (params['uri']?.isNotEmpty ?? false) {
          print('returning main view!');
          return DevToolsScaffold(
            key: Key('home'),
            tab: page,
            tabs: [
              TabPage('tab1', TabBody('Tab 1 (connected to ${params['uri']})')),
              TabPage('tab2', TabBody('Tab 2 (connected to ${params['uri']})')),
              TabPage('tab3', TabBody('Tab 3 (connected to ${params['uri']})')),
              TabPage('tab4', TabBody('Tab 4 (connected to ${params['uri']})')),
              TabPage('tab5', TabBody('Tab 5 (connected to ${params['uri']})')),
            ],
          );
        } else {
          print('returning connect screen!');
          return DevToolsScaffold.withChild(
            key: Key('connect'),
            child: Column(
              children: [
                Text('Connect!'),
                RaisedButton(
                  child: Text('Connect Me!'),
                  onPressed: () {
                    final routerDelegate = Router.of(context).routerDelegate
                        as DevToolsRouterDelegate;
                    print('connect button pressed!');
                    routerDelegate.pushScreenIfNotCurrent(
                        'tab1', {'uri': 'my vm service uri'});
                  },
                ),
              ],
            ),
          );
        }
      },
      otherRoute: (_, __, ___) {
        return DevToolsScaffold.withChild(
          key: Key('other'),
          child: Text('Other screen!'),
        );
      },
    };
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: DevToolsRouterDelegate(_getPage),
      routeInformationParser: DevToolsRouteInformationParser(),
    );
  }

  Page _getPage(BuildContext context, String page, Map<String, String> args) {
    print('Generating route for $page / $args');

    final route = routes.containsKey('/$page') ? '/$page' : homeRoute;

    return MaterialPage(
      child: routes[route](context, page, args),
    );
  }
}

class TabPage {
  final String name;
  final Widget content;

  TabPage(this.name, this.content);
}

@immutable
class TabBody extends StatelessWidget {
  final String text;

  TabBody(this.text);

  @override
  Widget build(BuildContext context) {
    final routerDelegate =
        Router.of(context).routerDelegate as DevToolsRouterDelegate;
    final isLightTheme =
        routerDelegate.currentConfiguration.args['theme'] != 'dark';
    return Container(
      decoration:
          BoxDecoration(color: isLightTheme ? Colors.white : Colors.grey),
      child: Column(
        children: [
          Text(text),
          Text(isLightTheme ? 'light' : 'dark'),
          RaisedButton(
            child: Text('Toggle theme!'),
            onPressed: () {
              routerDelegate.updateArgsIfNotCurrent(
                  {'theme': isLightTheme ? 'dark' : 'light'});
            },
          ),
        ],
      ),
    );
  }
}
