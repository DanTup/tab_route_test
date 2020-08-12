import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routeInformationParser: MyRouteInformationParser(),
      routerDelegate: MyRouterDelegate(),
    );
  }
}

class MyTabbedPage extends StatefulWidget {
  final String initialTab;
  const MyTabbedPage({Key key, this.initialTab}) : super(key: key);
  @override
  _MyTabbedPageState createState() => _MyTabbedPageState();
}

class _MyTabbedPageState extends State<MyTabbedPage>
    with SingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    Tab(text: 'LEFT'),
    Tab(text: 'RIGHT'),
  ];

  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: myTabs.length);
    _updateTab();
  }

  void _updateTab() {
    if (widget.initialTab != null) {
      final initialIndex = myTabs.indexWhere(
          (tab) => '/' + tab.text.toLowerCase() == widget.initialTab);
      if (initialIndex != -1) {
        _tabController.index = initialIndex;
      } else {
        // '/' will be default to LEFT.
        _tabController.index = 0;
      }
    }
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTab();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: myTabs,
          onTap: (newIndex) {
            if (_tabController.indexIsChanging) {
              // There are two ways
              // Changing the url directly

              // final PlatformRouteNameProvider provider = Router.of(context).routeNameProvider as PlatformRouteNameProvider;
              // provider.value = '/' + myTabs[newIndex].text.toLowerCase();

              // Or update the routes in router delegate directly
              final MyRouterDelegate delegate =
                  Router.of(context).routerDelegate as MyRouterDelegate;
              delegate.pushNewRoute('/' + myTabs[newIndex].text.toLowerCase());
            }
          },
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: myTabs.map((Tab tab) {
          final String label = tab.text.toLowerCase();
          return Center(
            child: Text(
              'This is the $label tab',
              style: const TextStyle(fontSize: 36),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class MyConfiguration {
  String currentRoute;
  MyConfiguration(this.currentRoute);
}

class MyRouterDelegate extends RouterDelegate<MyConfiguration>
    with ChangeNotifier {
  MyRouterDelegate();
  final routes = ListQueue<String>();

  void pushNewRoute(String routeName) {
    print('pushing new route $routeName');
    routes.add(routeName);
    // Needs to notify the router that the state has changed.
    notifyListeners();
  }

  @override
  Widget build(BuildContext context) {
    if (routes.isEmpty) {
      print('build: empty');
      return Container();
    }
    print('building: ${routes.last}');
    return MyTabbedPage(
      initialTab: routes.last,
    );
  }

  @override
  Future<bool> popRoute() {
    if (routes.length <= 1) {
      print('skipping popRoute');
      return SynchronousFuture<bool>(false);
    }
    print('removing last route');
    routes.removeLast();
    notifyListeners();
    return SynchronousFuture<bool>(true);
  }

  @override
  Future<void> setNewRoutePath(MyConfiguration configuration) {
    print('setting new route path "${configuration?.currentRoute}"');
    routes.add(configuration.currentRoute);
    return SynchronousFuture<void>(null);
  }

  @override
  MyConfiguration get currentConfiguration {
    if (routes.isEmpty) {
      print('returning null as current config');
      return null;
    }
    print('returning "${routes.last}" as current config');
    return MyConfiguration(routes.last);
  }
}

class MyRouteInformationParser extends RouteInformationParser<MyConfiguration> {
  @override
  Future<MyConfiguration> parseRouteInformation(
      RouteInformation routeInformation) {
    print('parsing route: ${routeInformation.location}');
    return SynchronousFuture<MyConfiguration>(
        MyConfiguration(routeInformation.location));
  }

  @override
  RouteInformation restoreRouteInformation(MyConfiguration configuration) {
    print('restoring route: ${configuration?.currentRoute}');
    return RouteInformation(location: configuration.currentRoute);
  }
}
