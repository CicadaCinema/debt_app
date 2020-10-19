import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'misc.dart';

class GatewayPage extends StatefulWidget {GatewayPage({Key key}) : super(key: key);
@override
_GatewayPageState createState() => _GatewayPageState();
}
class _GatewayPageState extends State<GatewayPage> {
  final _formKey = GlobalKey<FormState>();

  String _username;
  String _password;

  void _enterGateway(String action) async {
    try {
      switch (action) {
        case 'Register':
          UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
              email: _username,
              password: _password
          );
          break;
        case 'Login':
          UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: _username,
              password: _password
          );
          break;
        default:
          throw Exception('Invalid action parameter in _enterGateway() call.');
      }
    } on FirebaseAuthException catch (e) {
      showDialogBox('FirebaseAuthException caught', e.toString(), context);
    } catch (e) {
      showDialogBox('Unhandled Exception', e.toString(), context);
    }
  }

  Widget loginForm() {
    return Form(
        key: _formKey,
        child: Container(
          padding: EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              TextFormField(
                validator: (value) {
                  if (value == '') {
                    return 'Field must be non-empty';
                  }
                  _username=value;
                  return null;
                },
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextFormField(
                validator: (value) {
                  if (value == '') {
                    return 'Field must be non-empty';
                  }
                  _password=value;
                  return null;
                },
                decoration: InputDecoration(labelText: 'Password'),
              ),
              RaisedButton(
                child: Text('Register'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _enterGateway('Register');
                  }
                },
              ),
              RaisedButton(
                child: Text('Login'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _enterGateway('Login');
                  }
                },
              ),
            ],
          ),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gateway'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            loginForm(),
          ],
        ),
      ),
    );
  }
}