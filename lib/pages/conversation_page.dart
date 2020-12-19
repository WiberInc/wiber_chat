import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';
import '../services/media_service.dart';
import '../services/cloud_storage_service.dart';

import '../functions/datetime_formats.dart';

import '../models/conversation.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
  final String _conversationID;
  final String _receiverID;
  final String _receiverImage;
  final String _receiverName;

  ConversationPage(this._conversationID, this._receiverID, this._receiverName,
      this._receiverImage);

  @override
  State<StatefulWidget> createState() {
    return _ConversationPageState();
  }
}

class _ConversationPageState extends State<ConversationPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  final _messageTextController = TextEditingController();
  ScrollController _listViewController;
  AuthProvider _auth;

  String _messageText;

  _ConversationPageState() {
    _formKey = GlobalKey<FormState>();
    _listViewController = ScrollController();
    _messageText = '';
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).primaryColor,
          title: Row(children: [
            _userImageWidget(),
            SizedBox(
              width: _deviceWidth * 0.02,
            ),
            Text(
              this.widget._receiverName,
            ),
          ])),
      body: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _conversationPageUI(),
      ),
    );
  }

  Widget _conversationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _messageListView(),
            _messageField(_context),
          ],
        );
      },
    );
  }

  Widget _messageListView() {
    return Expanded(
      child: Container(
        width: _deviceWidth,
        child: StreamBuilder<Conversation>(
          stream:
              DBService.instance.getConversation(this.widget._conversationID),
          builder: (BuildContext _context, _snapshot) {
            Timer(
              Duration(milliseconds: 250),
              () => {
                _listViewController
                    .jumpTo(_listViewController.position.maxScrollExtent),
              },
            );

            var _conversationData = _snapshot.data;
            if (_conversationData != null) {
              if (_conversationData.messages.length != 0) {
                return ListView.builder(
                  controller: _listViewController,
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
                  itemCount: _conversationData.messages.length,
                  itemBuilder: (BuildContext _context, _index) {
                    var _message = _conversationData.messages[_index];
                    bool _isMe = _message.senderID == _auth.user.uid;
                    return _messageListViewChild(_isMe, _message);
                  },
                );
              } else {
                return Container();
              }
            } else {
              return SpinKitThreeBounce(
                color: Colors.blueGrey,
                size: 30.0,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _messageListViewChild(bool _isMe, Message _message) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment:
            _isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: <Widget>[
          !_isMe ? _userImageWidget() : Container(),
          !_isMe ? SizedBox(width: 5.0) : Container(),
          _message.type == MessageType.Text
              ? _textMessageBubble(
                  _isMe,
                  _message.content,
                  _message.timestamp,
                )
              : _imageMessageBubble(
                  _isMe,
                  _message.content,
                  _message.timestamp,
                ),
        ],
      ),
    );
  }

  Widget _userImageWidget() {
    return Container(
      width: _deviceHeight * 0.05,
      height: _deviceHeight * 0.05,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(500.0),
        child: CachedNetworkImage(
          imageUrl: this.widget._receiverImage,
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

  Widget _textMessageBubble(bool _isMe, String _message, Timestamp _timestamp) {
    DateTime _messageTime = _timestamp.toDate();
    /*List<Color> _colorScheme = _isMe
        ? [Theme.of(context).accentColor, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];*/
    return Container(
      constraints: BoxConstraints(
        minWidth: _deviceWidth * 0.30,
        maxWidth: _deviceWidth * 0.75,
      ),
      //width: _deviceWidth * 0.08 + _message.length,
      padding:
          EdgeInsets.only(left: 15.0, right: 15.0, top: 15.0, bottom: 10.0),
      decoration: BoxDecoration(
        color: _isMe ? Theme.of(context).accentColor : Colors.white,
        borderRadius: _isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
        /*gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),*/
      ),
      child: Column(
        crossAxisAlignment:
            _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            _message,
            style: TextStyle(
              fontSize: 16.0,
              color: _isMe ? Colors.white : Colors.black,
            ),
          ),
          SizedBox(
            height: 8.0,
          ),
          Column(
            crossAxisAlignment:
                _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Text(
                whenWasSend(_messageTime),
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: _isMe ? Colors.white54 : Colors.grey,
                ),
              ),
              Text(
                timeIn12HoursFormat(_messageTime),
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  color: _isMe ? Colors.white54 : Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imageMessageBubble(
      bool _isMe, String _imageURL, Timestamp _timestamp) {
    DateTime _messageTime = _timestamp.toDate();
    /*List<Color> _colorScheme = _isMe
        ? [Theme.of(context).accentColor, Color.fromRGBO(42, 117, 188, 1)]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];*/
    DecorationImage _image = DecorationImage(
      image: NetworkImage(_imageURL),
      fit: BoxFit.cover,
    );
    return Container(
      padding: EdgeInsets.only(
        left: 2.0,
        right: 2.0,
        top: 2.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        color: _isMe ? Theme.of(context).accentColor : Colors.white,
        borderRadius: _isMe
            ? BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
              )
            : BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
        /*gradient: LinearGradient(
          colors: _colorScheme,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),*/
      ),
      child: Column(
        crossAxisAlignment:
            _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: _deviceWidth * 0.60,
            height: _deviceHeight * 0.30,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20.0),
              child: Image.network(
                _imageURL,
                fit: BoxFit.cover,
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.blueGrey),
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(
            height: 10.0,
          ),
          Padding(
            padding: _isMe
                ? EdgeInsets.only(right: 10.0)
                : EdgeInsets.only(left: 10.0),
            child: Column(
              crossAxisAlignment:
                  _isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  whenWasSend(_messageTime),
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: _isMe ? Colors.white54 : Colors.grey,
                  ),
                ),
                Text(
                  timeIn12HoursFormat(_messageTime),
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    color: _isMe ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _messageField(BuildContext _context) {
    return Container(
      margin: EdgeInsets.only(
        left: _deviceWidth * 0.02,
        right: _deviceWidth * 0.02,
        top: _deviceHeight * 0.01 + 2.0,
        bottom: _deviceHeight * 0.01 + 2.0,
      ),
      child: Form(
        key: _formKey,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: _deviceHeight * 0.20,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                    left: _deviceWidth * 0.01, right: _deviceWidth * 0.04),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    _imageMessageButton(),
                    SizedBox(
                      width: _deviceWidth * 0.01,
                    ),
                    _messageTextField(),
                  ],
                ),
              ),
            ),
            _sendMessageButton(_context),
          ],
        ),
      ),
    );
  }

  Widget _messageTextField() {
    return Container(
      width: _deviceWidth * 0.55,
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        controller: _messageTextController,
        autocorrect: false,
        maxLines: null,
        validator: (_input) {
          if (_input.length == 0) {
            return "Please enter a message";
          }
          return null;
        },
        onChanged: (_input) {
          _formKey.currentState.save();
        },
        onSaved: (_input) {
          setState(() {
            _messageText = _input.trimRight();
          });
        },
        style: TextStyle(color: Colors.black),
        cursorColor: Theme.of(context).accentColor,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Send a message',
            hintStyle: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _sendMessageButton(BuildContext _context) {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).accentColor,
          borderRadius: BorderRadius.circular(100.0)),
      child: IconButton(
        icon: Icon(
          Icons.send,
          color: Colors.white,
        ),
        onPressed: () {
          if (_formKey.currentState.validate()) {
            DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _messageText,
                  timestamp: Timestamp.now(),
                  senderID: _auth.user.uid,
                  type: MessageType.Text),
            );
            _formKey.currentState.reset();
            _messageTextController.clear();
            //FocusScope.of(_context).unfocus();
          }
        },
      ),
    );
  }

  Widget _imageMessageButton() {
    return Container(
      child: IconButton(
        icon: Icon(
          Icons.camera_alt,
          color: Theme.of(context).accentColor,
        ),
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        color: Colors.white,
      ),
    );

    Container(
      color: Colors.green,
      width: 40.0,
      child: FloatingActionButton(
        onPressed: () async {
          var _image = await MediaService.instance.getImageFromLibrary();
          if (_image != null) {
            var _result = await CloudStorageService.instance
                .uploadMediaMessage(_auth.user.uid, _image);
            var _imageURL = await _result.ref.getDownloadURL();
            await DBService.instance.sendMessage(
              this.widget._conversationID,
              Message(
                  content: _imageURL,
                  senderID: _auth.user.uid,
                  timestamp: Timestamp.now(),
                  type: MessageType.Image),
            );
          }
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
