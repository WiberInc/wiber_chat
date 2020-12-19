import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'package:timeago/timeago.dart' as timeago;

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../pages/conversation_page.dart';

import '../models/contact.dart';

class SearchPage extends StatefulWidget {
  final double _height;
  final double _width;

  SearchPage(this._height, this._width);

  @override
  State<StatefulWidget> createState() {
    return _SearchPageState();
  }
}

class _SearchPageState extends State<SearchPage> {
  String _searchText;

  AuthProvider _auth;

  _SearchPageState() {
    _searchText = '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _searchPageUI(),
      ),
    );
  }

  Widget _searchPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _userSearchField(),
            _usersListView(),
          ],
        );
      },
    );
  }

  Widget _userSearchField() {
    return Container(
      width: this.widget._width,
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: TextField(
        autocorrect: false,
        style: TextStyle(
          color: Colors.white,
        ),
        onSubmitted: (_input) {
          setState(() {
            _searchText = _input;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white,
          ),
          labelStyle: TextStyle(color: Colors.white),
          hintText: 'Search',
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _usersListView() {
    return StreamBuilder<List<Contact>>(
      stream: DBService.instance.getUsersInDB(_searchText),
      builder: (_context, _snapshot) {
        var _usersData = _snapshot.data;
        if (_usersData != null) {
          _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
        }
        return _snapshot.hasData
            ? Expanded(
                child: Container(
                  child: ListView.builder(
                    itemCount: _usersData.length,
                    itemBuilder: (BuildContext _context, int _index) {
                      var _userData = _usersData[_index];
                      var _currentTime = DateTime.now();
                      var _recipientID = _userData.id;
                      var _isUserActive = !_userData.lastseen.toDate().isBefore(
                            _currentTime.subtract(
                              Duration(hours: 1),
                            ),
                          );
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 10.0),
                        child: ListTile(
                          onTap: () {
                            DBService.instance.createOrGetConversation(
                                _auth.user.uid, _recipientID,
                                (String _conversationID) {
                              NavigationService.instance.navigateToRoute(
                                MaterialPageRoute(builder: (_context) {
                                  return ConversationPage(
                                      _conversationID,
                                      _recipientID,
                                      _userData.name,
                                      _userData.image);
                                }),
                              );
                            });
                          },
                          title: Text(_userData.name),
                          leading: Container(
                            width: 60.0,
                            height: 60.0,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(500.0),
                              child: CachedNetworkImage(
                                imageUrl: _userData.image,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                placeholder: (context, url) => SpinKitThreeBounce(
                                  color: Colors.blueGrey,
                                  size: 15.0,
                                ),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                              ),
                            ),
                          ),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              _isUserActive
                                  ? Text(
                                      'Active now',
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.blueGrey,
                                      ),
                                    )
                                  : Text(
                                      'Last seen',
                                      style: TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.blueGrey),
                                    ),
                              _isUserActive
                                  ? Container(
                                      height: 10.0,
                                      width: 10.0,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(100.0),
                                      ),
                                    )
                                  : Text(
                                      timeago.format(
                                        _userData.lastseen.toDate(),
                                      ),
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )
            : Expanded(
                child: Align(
                  alignment: Alignment.center,
                  child: SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 30.0,
                  ),
                ),
              );
      },
    );
  }
}
