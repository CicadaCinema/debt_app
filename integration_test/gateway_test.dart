import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:debt_app/main.dart' as app;

// https://flutter.dev/docs/testing/integration-tests

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets("login and transaction test", (WidgetTester tester) async {
    // mandatory
    app.main();
    await tester.pumpAndSettle();

    // find key widgets in gateway screen
    final Finder emailField = find.widgetWithText(TextFormField, "Email");
    final Finder passwordField = find.widgetWithText(TextFormField, "Password");
    final Finder loginButton = find.widgetWithText(RaisedButton, "Login");

    // fill in login form and submit
    await tester.enterText(emailField, "computer@example.com");
    await tester.enterText(passwordField, "computer");
    await tester.tap(loginButton);

    // check for the static sign out button
    await tester.pumpAndSettle();
    await tester.idle();
    expect(find.text("Sign out"), findsOneWidget);

    // allow some time to connect to firebase - this may not be enough
    // TODO: this sometimes does not actually login - also I do not know what idle does
    // TODO: THIS QUITE LITERALLY SOMETIMES PASSES AND SOMETIMES FAILS!!!!!!!!
    await tester.idle();
    await Future.delayed(const Duration(seconds: 5), () {});
    await tester.idle();
    await tester.pumpAndSettle();
    await tester.idle();

    // check to see if we have signed in correctly
    expect(find.text("computer's balance:"), findsOneWidget);

    // check correctness of receive tab
    final Finder receiveTab = find.byKey(Key("tab_receive"));
    await tester.tap(receiveTab);
    await Future.delayed(const Duration(seconds: 2), () {});
    await tester.pumpAndSettle();
    await tester.idle();
    expect(find.text("Amount"), findsOneWidget);

    //check correctness of send tab
    final Finder sendTab = find.byKey(Key("tab_send"));
    await tester.tap(sendTab);
    await Future.delayed(const Duration(seconds: 2), () {});
    await tester.pumpAndSettle();
    await tester.idle();
    expect(find.text("Waiting for requests from other users..."), findsOneWidget);
  });
}
