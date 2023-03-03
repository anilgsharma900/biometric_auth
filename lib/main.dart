import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as error_code;
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_ios/local_auth_ios.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isDeviceSupport = false;
  List<BiometricType>? availableBiometrics;
  LocalAuthentication? auth;

  @override
  void initState() {
    super.initState();

    auth = LocalAuthentication();

    deviceCapability();
    _getAvailableBiometrics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<void> _getAvailableBiometrics() async {
    try {
      availableBiometrics = await auth?.getAvailableBiometrics();
      print("bioMetric: $availableBiometrics");

      if (availableBiometrics!.contains(BiometricType.strong) || availableBiometrics!.contains(BiometricType.fingerprint)) {
        final bool didAuthenticate = await auth!.authenticate(
            localizedReason: 'Unlock your screen with PIN, pattern, password, face, or fingerprint',
            options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'Unlock Ideal Group',
                cancelButton: 'No thanks',
              ),
              IOSAuthMessages(
                cancelButton: 'No thanks',
              ),
            ]);
        if (!didAuthenticate) {
          exit(0);
        }
      } else if (availableBiometrics!.contains(BiometricType.weak) || availableBiometrics!.contains(BiometricType.face)) {
        final bool didAuthenticate = await auth!.authenticate(
            localizedReason: 'Unlock your screen with PIN, pattern, password, face, or fingerprint',
            options: const AuthenticationOptions(stickyAuth: true),
            authMessages: const <AuthMessages>[
              AndroidAuthMessages(
                signInTitle: 'Unlock Ideal Group',
                cancelButton: 'No thanks',
              ),
              IOSAuthMessages(
                cancelButton: 'No thanks',
              ),
            ]);
        if (!didAuthenticate) {
          exit(0);
        }
      }
    } on PlatformException catch (e) {
      // availableBiometrics = <BiometricType>[];
      if (e.code == error_code.passcodeNotSet) {
        exit(0);
      }
      print("error: $e");
    }
  }

  void deviceCapability() async {
    final bool isCapable = await auth!.canCheckBiometrics;
    isDeviceSupport = isCapable || await auth!.isDeviceSupported();
  }
}
