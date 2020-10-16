import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
//import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appTitle = 'Debt App';

  Widget messageScreen(
      String titleText, IconData icon, Color iconColour, String iconText) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.green,
      ),
      home: Scaffold(
          appBar: AppBar(
            title: Text(titleText),
          ),
          body: Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 64, color: iconColour),
              Text(iconText, textScaleFactor: 2.0),
            ]),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    WidgetsFlutterBinding.ensureInitialized();
    return FutureBuilder(
      // initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // check for errors
        if (snapshot.hasError) {
          return messageScreen('Firebase Error', Icons.error, Colors.orange,
              'Error connecting to Firebase');
        }

        // once complete, show main screen
        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: appTitle,
            theme: ThemeData(
              visualDensity: VisualDensity.adaptivePlatformDensity,
              primarySwatch: Colors.green,
              buttonTheme: ButtonThemeData(
                buttonColor: Colors.green,
                textTheme: ButtonTextTheme.primary,
              ),
            ),
            home: GatewayPage(title: 'Gateway'),
          );
        }

        // show loading screen while waiting for initialization to complete
        return messageScreen('Connecting to Firebase', Icons.refresh,
            Colors.green, 'Loading ...');
        ;
      },
    );
  }
}

class GatewayPage extends StatefulWidget {
  GatewayPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _GatewayPageState createState() => _GatewayPageState();
}

class _GatewayPageState extends State<GatewayPage> {
  final _formKey = GlobalKey<FormState>();

  String _username;
  String _password;

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
                return null;
              },
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextFormField(
              validator: (value) {
                if (value == '') {
                  return 'Field must be non-empty';
                }
                return null;
              },
              decoration: InputDecoration(labelText: 'Password'),
            ),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text('Text'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
