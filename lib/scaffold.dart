import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tab_route_test/main.dart';
import 'package:tab_route_test/routing.dart';

class DevToolsScaffold extends StatefulWidget {
  const DevToolsScaffold({
    Key key,
    @required this.tabs,
    this.tab,
  })  : assert(tabs != null),
        super(key: key);

  DevToolsScaffold.withChild({Key key, @required Widget child})
      : this(
          key: key,
          tabs: [TabPage('Single', SimpleScreen(child))],
        );

  final List<TabPage> tabs;
  final String tab;

  @override
  State<StatefulWidget> createState() => DevToolsScaffoldState();
}

class DevToolsScaffoldState extends State<DevToolsScaffold>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _setupTabController();
  }

  @override
  void dispose() {
    _tabController?.dispose();

    super.dispose();
  }

  @override
  void didUpdateWidget(DevToolsScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    print('widget update!');

    if (widget.tab != null &&
        widget.tabs[_tabController.index].name != widget.tab) {
      print(
          'tab has changed from ${widget.tabs[_tabController.index].name} to ${widget.tab}!');
      // If the page changed (eg. the route was modified by pressing back in the
      // browser), animate to the new one.
      final newIndex = widget.tabs.indexWhere((t) => t.name == widget.tab);
      if (newIndex > -1) {
        _tabController.animateTo(newIndex);
      }
    } else {
      print('tab did not change!');
    }
  }

  void _setupTabController() {
    _tabController?.dispose();
    _tabController = TabController(length: widget.tabs.length, vsync: this);

    // Set initial tab
    if (widget.tab != null) {
      final initialIndex =
          widget.tabs.indexWhere((screen) => screen.name == widget.tab);
      if (initialIndex != -1) {
        _tabController.index = initialIndex;
      }
    }

    _tabController.addListener(() {
      final screen = widget.tabs[_tabController.index];

      final routerDelegate =
          Router.of(context).routerDelegate as DevToolsRouterDelegate;
      print('tab controller change!');
      routerDelegate.pushScreenIfNotCurrent(screen.name);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabs: widget.tabs
            .map((t) => Text(
                  t.name,
                  style: TextStyle(color: Colors.black, fontSize: 30),
                ))
            .toList(),
      ),
      body: TabBarView(
        controller: _tabController,
        children: widget.tabs.map((t) => t.content).toList(),
      ),
    );
  }
}

class SimpleScreen extends StatelessWidget {
  const SimpleScreen(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
