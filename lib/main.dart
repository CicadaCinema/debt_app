import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'gateway.dart';
import 'menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MaterialApp(
      //title: 'Debt App',
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primarySwatch: Colors.green,
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.green,
          textTheme: ButtonTextTheme.primary,
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => FirebaseBuilder(),
      },
    )
  );
}

class FirebaseBuilder extends StatelessWidget {
  Widget messageScreen(String titleText, IconData icon, Color iconColour, String iconText) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
      ),
      body: Center(
        child:
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 64, color: iconColour),
          Text(iconText, textScaleFactor: 2.0),
        ]),
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // initialize FlutterFire
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        // check for errors
        if (snapshot.hasError) {
          return messageScreen('Firebase Error', Icons.error, Colors.orange, 'Error connecting to Firebase');
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return StreamBuilder<User>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (BuildContext context, AsyncSnapshot<User> user){
              // this is required to prevent the transition from happening multiple times
              // just one condition is unreliable by itself
              bool _displayGateway = true;
              if (FirebaseAuth.instance.currentUser != null && FirebaseAuth.instance.currentUser.uid != null){
                _displayGateway = false;
              }

              var _newPage = _displayGateway ? GatewayPage() : MainMenu();
              var _previousPage = !_displayGateway ? GatewayPage() : MainMenu();

              double _direction = _displayGateway ? 1.0 : -1.0;

              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: _newPage,
                transitionBuilder: (Widget child, Animation<double> animation) {
                  Animation<Offset> _slideAnimationPage1 = Tween<Offset>(begin: Offset(0.0, 0.0), end: Offset(0.0, _direction)).animate(animation);
                  Animation<Offset> _slideAnimationPage2 = Tween<Offset>(begin: Offset(0.0, -1*_direction), end: Offset(0.0, 0.0)).animate(animation);
                  return Stack(
                    children: <Widget>[
                      SlideTransition(position: _slideAnimationPage1, child: _previousPage),
                      SlideTransition(position: _slideAnimationPage2, child: _newPage),
                    ],
                  );
                  //return ScaleTransition(child: child, scale: animation);
                },

              );
            },
          );
        }

        // show loading screen while waiting for initialization to complete
        return messageScreen('Connecting to Firebase', Icons.refresh, Colors.green, 'Loading ...');
      },
    );
  }
}