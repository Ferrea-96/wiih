import 'dart:async';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiih/src/app/app.dart';
import 'package:wiih/src/app/firebase_options.dart';

Future<Widget> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final AndroidAppCheckProvider providerAndroid = kReleaseMode
      ? const AndroidPlayIntegrityProvider()
      : const AndroidDebugProvider();
  final AppleAppCheckProvider providerApple =
      kReleaseMode ? const AppleDeviceCheckProvider() : const AppleDebugProvider();

  await FirebaseAppCheck.instance.activate(
    providerAndroid: providerAndroid,
    providerApple: providerApple,
  );

  if (!kReleaseMode) {
    // Helpful when registering debug tokens in the Firebase console.
    unawaited(
      FirebaseAppCheck.instance
          .getToken(true)
          .then((token) => debugPrint('App Check debug token: $token'))
          .catchError((error) =>
              debugPrint('App Check debug token unavailable: $error')),
    );
  }

  return const WiihApp();
}
