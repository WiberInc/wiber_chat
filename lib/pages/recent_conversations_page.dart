import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../services/db_service.dart';
import '../services/navigation_service.dart';

import '../models/conversation.dart';
import '../models/message.dart';

import '../functions/datetime_formats.dart';

import '../pages/conversation_page.dart';

class RecentConversationsPage extends StatelessWidget {
  final double _height;
  final double _width;

  RecentConversationsPage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationsListViewWidget(),
      ),
    );
  }

  Widget _conversationsListViewWidget() {
    return Builder(
      builder: (BuildContext _context) {
        var _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _height,
          width: _width,
          child: StreamBuilder<List<ConversationSnippet>>(
            stream: DBService.instance.getUserConversations(_auth.user.uid),
            builder: (_context, _snapshot) {
              var _data = _snapshot.data;
              if (_data != null) {
                _data.removeWhere((_c) {
                  return _c.timestamp == null;
                });
                return _data.length != 0
                    ? _listViewWidget(_data)
                    : Align(
                        child: Text(
                          'No conversations yet!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 25.0,
                          ),
                        ),
                      );
              } else {
                return SpinKitThreeBounce(
                  color: Colors.blueGrey,
                  size: 30.0,
                );
              }
            },
          ),
        );
      },
    );
  }

  Widget _listViewWidget(_data) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      itemCount: _data.length,
      itemBuilder: (_context, _index) {
        return _tileContainer(_data[_index]);
      },
    );
  }

  Widget _tileContainer(_inputData) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        NavigationService.instance.navigateToRoute(
          MaterialPageRoute(builder: (BuildContext _context) {
            return ConversationPage(_inputData.conversationID, _inputData.id,
                _inputData.name, _inputData.image);
          }),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _width * 0.03,
          vertical: _height * 0.02,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _listLeadingWidget(_inputData),
            SizedBox(
              width: _width * 0.04,
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _listTitleWidget(_inputData),
                        _subTitleWidget(_inputData),
                      ],
                    ),
                  ),
                  Container(
                    width: _width * 0.25,
                    child: _listTileTrailingWidget(_inputData.timestamp),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _listLeadingWidget(_inputData) {
    return Container(
      width: _width * 0.13,
      height: _width * 0.13,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(500.0),
        child: CachedNetworkImage(
          imageUrl: _inputData.image,
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
    );
  }

  Widget _listTitleWidget(_inputData) {
    return Text(
      _inputData.name,
      style: TextStyle(
        fontSize: 18,
      ),
    );
  }

  Widget _subTitleWidget(_inputData) {
    return Container(
      child: _inputData.type == MessageType.Text
          ? Text(
              _inputData.lastMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            )
          : Row(
              children: [
                Text(
                  'File',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.blueGrey,
                  ),
                ),
                SizedBox(
                  width: 5.0,
                ),
                Icon(
                  Icons.attachment,
                  size: 18,
                  color: Colors.blueGrey,
                ),
              ],
            ),
    );
  }

  Widget _listTileTrailingWidget(Timestamp _lastMessageTimestamp) {
    DateTime _messageTime = _lastMessageTimestamp.toDate();
    int _elapsedTime = _messageTime.difference(DateTime.now()).inDays;
    Widget _whenWasSend;
    if (_elapsedTime == 0) {
      _whenWasSend = Text(
        timeIn12HoursFormat(_messageTime),
        style: TextStyle(
          fontSize: 14,
          color: Colors.blueGrey,
        ),
      );
    } else {
      _whenWasSend = Text(
        whenWasSend(_messageTime),
        style: TextStyle(
          fontSize: 14,
          color: Colors.blueGrey,
        ),
      );
    }
    return Align(
      alignment: Alignment.topRight,
      child: _whenWasSend,
    );
  }
}
