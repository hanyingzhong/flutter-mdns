/*
  mDNS Plugin Example
  Flutter client demonstrating browsing for Chromecasts
  on your local network

  Copyright (c) David Thorpe 2019
  Please see the LICENSE file for licensing information
*/

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import './bloc/app.dart';
import './pages/service_list.dart';

/////////////////////////////////////////////////////////////////////

void main() {
  runApp(BlocProvider<AppBloc>(
      create: (context) {
        AppStateUninitialized init;
        return AppBloc(init)..add(AppEventStart());
      },
      child: MyApp()));
}

/////////////////////////////////////////////////////////////////////

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // CONSTRUCTORS ///////////////////////////////////////////////////

  @override
  void initState() {
    super.initState();
  }

  // METHODS ////////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              title: const Text('Chromecast Browser'),
            ),
            body: BlocBuilder<AppBloc, AppState>(builder: (context, state) {
              if (state is AppStateUninitialized) {
                return const Placeholder();
              } else {
                return ServiceList();
              }
            })));
  }
}
