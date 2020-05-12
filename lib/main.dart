import 'dart:html';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => MyTabbedPage(initialTab: settings.name),
        );
      },
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

  updateAddressBar(String tabName) {
    window.history.pushState(null, 'title', '#/$tabName');
    document.title = tabName;
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
              final tabName = myTabs[newIndex].text.toLowerCase();
              final previousTabIndex = _tabController.previousIndex;
              final previousTabName =
                  myTabs[previousTabIndex].text.toLowerCase();
              updateAddressBar(tabName);
              // Back button doesn't work correctly, with or without this.
              // ModalRoute.of(context).addLocalHistoryEntry(LocalHistoryEntry(
              //   onRemove: () {
              //     _tabController.animateTo(previousTabIndex);
              //     // updateAddressBar(previousTabName);
              //   },
              // ));
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
