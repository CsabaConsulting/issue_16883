// Copyright 2024 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:developer';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:inspector_gadget/ai_service.dart';

import 'package:inspector_gadget/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initFirebase();
  await Firebase.initializeApp();
  await FirebaseAuth.instance.signInAnonymously();

  runApp(GenerativeAISample());
}

Future<void> initFirebase() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await FirebaseAppCheck.instance.activate(
    androidProvider: AndroidProvider.debug,
  );

  try {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    final user = userCredential.user;

    if (user != null) {
      log('Signed in anonymously with user ID: ${user.uid}');
    } else {
      log('Error signing in anonymously: $userCredential');
    }
  } on FirebaseAuthException catch (e) {
    log('Error signing in anonymously: ${e.message}');
  }
}

class GenerativeAISample extends StatelessWidget {
  const GenerativeAISample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Issue 16883',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          brightness: Brightness.dark,
          seedColor: const Color.fromARGB(255, 171, 222, 244),
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _response = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter + Vertex AI'),
      ),
      body: Center(
        child: Text(_response),
      ),
      floatingActionButton: IconButton(
        icon: const Icon(Icons.functions),
        onPressed: () async {
          final response = (await AiService()
                  .chatStep("What's the weather in Fresno, California?"))
              ?.text;
          if (response != null) {
            setState(() {
              _response = response;
            });
          }
        },
      ),
    );
  }
}
