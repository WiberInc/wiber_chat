import 'package:flutter/material.dart';

import 'profile_page.dart';
import 'recent_conversations_page.dart';
import 'search_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  double _height;
  double _width;

  TabController _tabController;

  _HomePageState() {
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'wiber',
              style: TextStyle(
                fontFamily: 'Croogla',
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              width: 5.0,
            ),
            Text(
              'Chat',
              style: TextStyle(
                color: Theme.of(context).accentColor,
                fontFamily: 'VarelaRound',
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        bottom: TabBar(
          unselectedLabelColor: Colors.white,
          indicatorColor: Theme.of(context).accentColor,
          labelColor: Theme.of(context).accentColor,
          controller: _tabController,
          tabs: [
            Tab(
              icon: Icon(
                Icons.people_outline,
                size: 25.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.chat_bubble_outline,
                size: 25.0,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.person_outline,
                size: 25.0,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: _tabBarPages(),
      ),
    );
  }

  Widget _tabBarPages() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        SearchPage(_height, _width),
        RecentConversationsPage(_height, _width),
        ProfilePage(_height, _width),
      ],
    );
  }
}
