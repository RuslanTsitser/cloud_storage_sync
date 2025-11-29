import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:cloud_storage_sync/cloud_storage_sync.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _cloudStatus = 'Unknown';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String cloudStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      final isAvailable = await CloudStorageSync.instance.isCloudStorageAvailable();
      cloudStatus = isAvailable ? 'Available' : 'Not Available';
    } on PlatformException {
      cloudStatus = 'Failed to get cloud storage status.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _cloudStatus = cloudStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Cloud Storage Sync Example'),
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Cloud Storage Status: $_cloudStatus'),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        setState(() => _isLoading = true);
                        await initPlatformState();
                      },
                      child: const Text('Refresh Status'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
