import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/core/navigation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_windows/local_auth_windows.dart';

class BiometricPage extends StatefulWidget {
  final bool usercanpopDialog;
  const BiometricPage({super.key, this.usercanpopDialog = false});

  @override
  State<BiometricPage> createState() => _BiometricPageState();
}

class _BiometricPageState extends State<BiometricPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  bool _isDeviceSupported = false;
  bool _isAuthenticating = false;
  String _authStatus = 'Not Authorized';

  @override
  void initState() {
    super.initState();
    _checkDeviceSupport();
    _authenticateOnStart();
  }

  Future<void> _checkDeviceSupport() async {
    final isSupported = await _auth.isDeviceSupported();
    if (mounted) {
      setState(() => _isDeviceSupported = isSupported);
    }
  }

  Future<void> _authenticateOnStart() async {
    await _authenticate();
  }

  Future<void> _authenticate() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _authStatus = 'Authenticating';
    });

    try {
      final authenticated = await _auth.authenticate(
        localizedReason: 'Please authenticate to show account balance',
        authMessages: const <AuthMessages>[
          WindowsAuthMessages(),
          AndroidAuthMessages(
            signInTitle: 'Oops! Biometric authentication required!',
          ),
          IOSAuthMessages(),
        ],
        options: const AuthenticationOptions(stickyAuth: true),
      );

      if (!mounted) return;

      setState(() {
        _isAuthenticating = false;
        _authStatus = authenticated ? 'Authorized' : 'Not Authorized';
      });

      if (authenticated) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showTryAgainDialog();
      }
    } on PlatformException catch (e) {
      if (!mounted) return;

      setState(() {
        _isAuthenticating = false;
        _authStatus = 'Error - ${e.message}';
      });
      _showTryAgainDialog();
    }
  }

  void _showTryAgainDialog() {
    showDialog(
      context: NavigationService.navigatorKey.currentContext!,
      barrierDismissible: widget.usercanpopDialog,
      builder: (context) => PopScope(
        canPop: widget.usercanpopDialog,
        child: AlertDialog(
          title: const Text('Authentication Failed'),
          content: const Text('Please try authenticating again.'),
          actions: [
            TextButton(
              onPressed: () {
                NavigationService.pop();
                _authenticate();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(appBar: AppBar(), body: SizedBox()),
    );
  }
}
