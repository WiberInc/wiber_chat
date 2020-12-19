import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../providers/auth_provider.dart';

import '../services/db_service.dart';

import '../models/contact.dart';

class ProfilePage extends StatelessWidget {
  final double _height;
  final double _width;

  AuthProvider _auth;

  ProfilePage(this._height, this._width);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor,
      height: _height,
      width: _width,
      child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _profilePageUI(),
      ),
    );
  }

  Widget _profilePageUI() {
    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Contact>(
          stream: DBService.instance.getUserData(_auth.user.uid),
          builder: (_context, _snapshot) {
            var _userData = _snapshot.data;
            return _snapshot.hasData
                ? Align(
                    child: SizedBox(
                      height: _height * 50,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          _userImageWidget(_userData.image),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              _userNameWidget(_userData.name),
                              SizedBox(
                                width: 10.0,
                              ),
                              _userLastnameWidget(_userData.lastname),
                            ],
                          ),
                          _userEmailWidget(_userData.email),
                          _logoutButton(),
                        ],
                      ),
                    ),
                  )
                : SpinKitThreeBounce(
                    color: Colors.blueGrey,
                    size: 30.0,
                  );
          },
        );
      },
    );
  }

  Widget _userImageWidget(String _image) {
    double _imageRadius = _height * 0.20;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(500.0),
        child: CachedNetworkImage(
          imageUrl: _image,
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

  Widget _userNameWidget(String _userName) {
    return Container(
      height: _height * 0.05,
      child: Text(
        _userName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
        ),
      ),
    );
  }

  Widget _userLastnameWidget(String _userLastname) {
    return Container(
      height: _height * 0.05,
      child: Text(
        _userLastname,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 25.0,
        ),
      ),
    );
  }

  Widget _userEmailWidget(String _userEmail) {
    return Container(
      height: _height * 0.05,
      width: _width,
      child: Text(
        _userEmail,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.blueGrey,
          fontSize: 18.0,
        ),
      ),
    );
  }

  Widget _logoutButton() {
    return Container(
      width: _width * 0.80,
      child: MaterialButton(
        onPressed: () {
          _auth.logoutUser(() {});
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.red,
        child: Text(
          'Logout',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.w300,
            fontFamily: 'VarelaRound',
          ),
        ),
      ),
    );
  }
}
