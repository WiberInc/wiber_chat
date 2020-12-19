import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

import '../services/snackbar_service.dart';
import '../services/navigation_service.dart';

class LoginPage extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool showSpinner = false;

  bool _rememberMe = false;
  double _deviceHeight;
  double _deviceWidth;

  GlobalKey<FormState> _formKey;
  AuthProvider _auth;

  String _email;
  String _password;

  _LoginPageState() {
    _formKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle.light,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: ChangeNotifierProvider<AuthProvider>.value(
              value: AuthProvider.instance,
              child: loginPageUI(),
            ),
          ),
        ),
      ),
    );
  }

  Widget loginPageUI() {
    return Builder(
      builder: (BuildContext _context) {
        SnackBarService.instance.buildContext = _context;
        _auth = Provider.of<AuthProvider>(_context);
        return Container(
          height: _deviceHeight,
          padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.10),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _headingWidget(),
              _inputForm(),
              _loginButton(),
              _registerButton(),
            ],
          ),
        );
      }
    );
  }

  Widget _headingWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Image.asset(
          'assets/images/wiberapplogo.png',
          width: 60.0,
        ),
        SizedBox(
          width: 10.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
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
      ],
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
          children: [
            _emailTextField(),
            SizedBox(
              height: 20.0,
            ),
            _passwordTextField(),
          ],
      ),
      ),
    );
  }

  Widget _emailTextField() {
    return Container(
      alignment: Alignment.centerLeft,
      child: TextFormField(
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
          hintText: 'you@email.com',
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
          return _input.length != 0
              ? null
              : 'Please enter a password';
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
          hintText: 'Enter your password',
          hintStyle: TextStyle(
            color: Colors.blueGrey,
          ),
        ),
      ),
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: FlatButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        padding: EdgeInsets.only(right: 0.0),
        child: Text(
          'Forgot Password?',
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: _rememberMe,
              checkColor: Colors.blueAccent,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value;
                });
              },
            ),
          ),
          Text(
            'Remember me',
          ),
        ],
      ),
    );
  }

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Align(
          alignment: Alignment.center,
          child: CircularProgressIndicator(),
        )
        : Container(
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          if (_formKey.currentState.validate()) {
            _auth.loginUserWithEmailAndPassword(_email, _password);
          }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Theme.of(context).accentColor,
        child: Text(
          'Login',
          style: TextStyle(
            color: Colors.white,
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'VarelaRound',
          ),
        ),
      ),
    );
  }

  Widget _SignInWithText() {
    return Container(
      padding: EdgeInsets.only(top : 30.0),
      child: Text(
        'Or sign in with',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSocialBtn(Function onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50.0,
        width: 50.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialBtnRow() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildSocialBtn(
                () => print('Login with Facebook'),
            AssetImage(
              'assets/images/facebook.jpg',
            ),
          ),
          _buildSocialBtn(
                () => print('Login with Google'),
            AssetImage(
              'assets/images/google.jpg',
            ),
          ),
        ],
      ),
    );
  }

  Widget _registerButton() {
    return Row(
      children: [
        Text(
          'Don\'t have an Account? ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          width: 5.0,
        ),
        GestureDetector(
          onTap: () {
            NavigationService.instance.navigateTo('register');
          },
          child: InkWell(
            //onTap: () => Navigator.pushNamed(context, RegistrationScreen.id),
            child: Text(
              'Sign Up',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}