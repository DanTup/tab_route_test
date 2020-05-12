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
      routePackageParser: MyRoutePackageParser(),
      routerDelegate: MyRouterDelegate(this),
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
    if (widget.initialTab != null) {
      final initialIndex = myTabs.indexWhere(
          (tab) => '/' + tab.text.toLowerCase() == widget.initialTab);
      if (initialIndex != -1) {
        _tabController.index = initialIndex;
      }
    }
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
              Navigator.pushNamed(
                  context, '/' + myTabs[newIndex].text.toLowerCase());
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

final navKey = GlobalKey();

class MyConfiguration {
  String currentRoute;
  MyConfiguration(this.currentRoute);
}

class MyRouterDelegate extends RouterDelegate<MyConfiguration>
    with PopNavigatorRouterDelegateMixin<MyConfiguration> {
  MyRouterDelegate(this.state);
  _MyAppState state;
  final routes = ListQueue<String>();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      pages: [
        MaterialPage(
          builder: (context) => MyTabbedPage(
            initialTab: routes.isNotEmpty ? routes.last : null,
          ),
        )
      ],
      onPopPage: (route, result) {
        routes.removeLast();
        rebuild??
        return true;
      },
    );
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => navKey;

  @override
  Future<void> setNewRoutePath(MyConfiguration configuration) {
    routes.add(configuration.currentRoute);
    return SynchronousFuture<void>(null);
  }
}

class MyRoutePackageParser extends RoutePackageParser {
  @override
  Future<MyConfiguration> parse(RoutePackage routePackage) async {
    return MyConfiguration(routePackage.routeName);
  }
}
