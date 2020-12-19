import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../services/media_service.dart';
import '../services/navigation_service.dart';
import '../services/cloud_storage_service.dart';
import '../services/db_service.dart';
import '../services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RegistrationPageState();
  }
}

class _RegistrationPageState extends State<RegistrationPage> {
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _name;
  String _lastname;
  String _email;
  String _password;
  File _image;

  _RegistrationPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Stack(
          children: <Widget>[
            Container(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: ChangeNotifierProvider<AuthProvider>.value(
                  value: AuthProvider.instance,
                  child: registrationPageUI(),
                ),
              ),
            ),
          ],
        ));
  }

  Widget registrationPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceHeight,
          padding: EdgeInsets.only(
              top: _deviceWidth * 0.10,
              left: _deviceWidth * 0.10,
              right: _deviceWidth * 0.10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headingWidget(),
              _inputForm(),
              _registerButton(),
              _backToLoginPageButton(),
            ],
          ),
        );
      },
    );
  }

  Widget _headingWidget() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'wiber',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Croogla',
                  fontSize: 40.0,
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
                  fontSize: 30.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Text(
            'Enter your details',
            style: TextStyle(
              fontFamily: 'VarelaRound',
              fontSize: 25.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _imageSelectorWidget(),
            SizedBox(
              height: 20.0,
            ),
            _nameTextField(),
            _lastnameTextField(),
            _emailTextField(),
            _passwordTextField(),
          ],
        ),
      ),
    );
  }

  Widget _imageSelectorWidget() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () async {
          File _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
            height: _image != null ? 150.0 : 100,
            width: _image != null ? 150.0 : 100,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(500.0),
                image: _image != null
                    ? DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_image),
                      )
                    : null),
            child: _image == null
                ? Icon(
                    Icons.camera_alt,
                    size: 40.0,
                    color: Theme.of(context).accentColor,
                  )
                : null),
      ),
    );
  }

  Widget _nameTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        autocorrect: false,
        validator: (_input) {
          return _input.length != 0 ? null : 'Please enter a name';
        },
        onSaved: (_input) {
          setState(() {
            _name = _input;
          });
        },
        cursorColor: Theme.of(context).accentColor,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'VarelaRound',
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          prefixIcon: Icon(
            Icons.perm_identity,
            color: Colors.white,
          ),
          labelText: 'Name',
          labelStyle: TextStyle(
            color: Colors.blueGrey,
          ),
          hintText: 'Your name',
          hintStyle: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _lastnameTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        textCapitalization: TextCapitalization.sentences,
        autocorrect: false,
        validator: (_input) {
          return _input.length != 0 ? null : 'Please enter a name';
        },
        onSaved: (_input) {
          setState(() {
            _lastname = _input;
          });
        },
        cursorColor: Theme.of(context).accentColor,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'VarelaRound',
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          prefixIcon: Icon(
            Icons.perm_identity,
            color: Colors.white,
          ),
          labelText: 'Lastname',
          labelStyle: TextStyle(
            color: Colors.blueGrey,
          ),
          hintText: 'Your last name',
          hintStyle: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        autofillHints: [AutofillHints.email],
        keyboardType: TextInputType.emailAddress,
        autocorrect: false,
        validator: (_input) {
          return _input.length != 0 && _input.contains('@')
              ? null
              : 'Please enter a valid email';
        },
        onSaved: (_input) {
          setState(() {
            _email = _input;
          });
        },
        cursorColor: Theme.of(context).accentColor,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'VarelaRound',
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          prefixIcon: Icon(
            Icons.email,
            color: Colors.white,
          ),
          labelText: 'Email',
          labelStyle: TextStyle(
            color: Colors.blueGrey,
          ),
          hintText: 'your@email.com',
          hintStyle: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _passwordTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
        obscureText: true,
        autocorrect: false,
        validator: (_input) {
          return _input.length != 0 ? null : 'Please enter a password';
        },
        onSaved: (_input) {
          setState(() {
            _password = _input;
          });
        },
        cursorColor: Theme.of(context).accentColor,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'VarelaRound',
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(top: 10.0, bottom: 10.0),
          prefixIcon: Icon(
            Icons.lock,
            color: Colors.white,
          ),
          labelText: 'Password',
          labelStyle: TextStyle(
            color: Colors.blueGrey,
          ),
          hintText: 'Your password',
          hintStyle: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _registerButton() {
    return _auth.status != AuthStatus.Authenticating
        ? Container(
            width: double.infinity,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState.validate() && _image != null) {
                  _auth.registerUserWithEmailAndPassword(_email, _password,
                      (String _uid) async {
                    var _result = await CloudStorageService.instance
                        .uploadUserImage(_uid, _image);
                    var _imageURL = await _result.ref.getDownloadURL();
                    await DBService.instance.createUserInDB(
                        _uid, _name, _lastname, _email, _imageURL);
                  });
                }
              },
              padding: EdgeInsets.all(15.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              color: Theme.of(context).accentColor,
              child: Text(
                'Register',
                style: TextStyle(
                  color: Colors.white,
                  letterSpacing: 1.5,
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'VarelaRound',
                ),
              ),
            ),
          )
        : Align(
            alignment: Alignment.center,
            child: CircularProgressIndicator(),
          );
  }

  Widget _backToLoginPageButton() {
    return GestureDetector(
      onTap: () {
        NavigationService.instance.goBack();
      },
      child: Container(
        height: _deviceHeight * 0.06,
        width: _deviceWidth,
        child: Icon(
          Icons.arrow_back,
          size: 30.0,
        ),
      ),
    );
  }
}
