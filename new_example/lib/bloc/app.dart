/*
  mDNS Plugin Example
  Flutter client demonstrating browsing for Chromecasts
  on your local network

  Copyright (c) David Thorpe 2019
  Please see the LICENSE file for licensing information
*/

import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mdns_plugin/mdns_plugin.dart';
import '../models/service_list.dart';

/////////////////////////////////////////////////////////////////////
// EVENT

enum AppEventDiscoveryState { Started, Stopped, Restart }

enum AppEventServiceState { Found, Resolved, Updated, Removed }

abstract class AppEvent {}

class AppEventStart extends AppEvent {
  @override
  String toString() => 'AppEventStart';
}

class AppEventDiscovery extends AppEvent {
  AppEventDiscoveryState state;

  // CONSTRUCTOR ////////////////////////////////////////////////////

  // ignore: sort_constructors_first
  AppEventDiscovery(this.state);

  // GETTERS AND SETTERS ////////////////////////////////////////////

  @override
  String toString() => 'AppEventDiscovery($state)';
}

class AppEventService extends AppEvent {
  AppEventServiceState state;
  MDNSService service;

  // CONSTRUCTOR ////////////////////////////////////////////////////

  AppEventService(this.state, this.service);

  // GETTERS AND SETTERS ////////////////////////////////////////////

  @override
  String toString() => 'AppEventService($state,$service)';
}

/////////////////////////////////////////////////////////////////////
// STATE

enum AppStateAction { ShowToast }

// ignore: public_member_api_docs
abstract class AppState {}

// ignore: public_member_api_docs
class AppStateUninitialized extends AppState {
  @override
  String toString() => 'AppStateUninitialized';
}

// ignore: public_member_api_docs
class AppStarted extends AppState {
  @override
  String toString() => 'AppStarted';
}

// ignore: public_member_api_docs
class AppUpdated extends AppState {
  // ignore: public_member_api_docs
  ServiceList services;
  // ignore: public_member_api_docs
  AppStateAction action;
  // ignore: public_member_api_docs
  MDNSService service;

  // CONSTRUCTOR ////////////////////////////////////////////////////

  // ignore: sort_constructors_first
  AppUpdated(this.services, {this.service, this.action});

  // GETTERS AND SETTERS ////////////////////////////////////////////

  @override
  String toString() => 'AppUpdated($service,$action)';
}

/////////////////////////////////////////////////////////////////////
// BLOC

class AppBloc extends Bloc<AppEvent, AppState> implements MDNSPluginDelegate {
  // ignore: prefer_single_quotes
  final String serviceType = "_googlecast._tcp";
  MDNSPlugin _mdns;
  final ServiceList _services = ServiceList();

  // ignore: sort_constructors_first
  AppBloc(AppState initialState) : super(initialState);

  // EVENT MAPPING //////////////////////////////////////////////////

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppEventStart) {
      // Start discovery
      _mdns = MDNSPlugin(this);
      _mdns.startDiscovery(serviceType, enableUpdating: true);
    }

    if (event is AppEventDiscovery) {
      // Remove all services and update the application
      _services.removeAll();
      // If restart then call discovery again
      if (event.state == AppEventDiscoveryState.Restart) {
        _mdns.startDiscovery(serviceType);
        yield AppUpdated(_services, action: AppStateAction.ShowToast);
      } else {
        yield AppUpdated(_services);
      }
    }

    if (event is AppEventService) {
      switch (event.state) {
        case AppEventServiceState.Found:
          // We don't add the service when it's found, but only when
          // it's resolved or updated
          break;
        case AppEventServiceState.Resolved:
          print(event.service);
          _services.update(event.service);
          break;
        case AppEventServiceState.Updated:
          print(event.service);
          _services.update(event.service);
          break;
        case AppEventServiceState.Removed:
          _services.remove(event.service);
          break;
      }
      yield AppUpdated(_services, service: event.service);
    }
  }

  // MDNS PLUGIN DELEGATE  //////////////////////////////////////////

  @override
  void onDiscoveryStarted() =>
      add(AppEventDiscovery(AppEventDiscoveryState.Started));
  @override
  void onDiscoveryStopped() =>
      add(AppEventDiscovery(AppEventDiscoveryState.Stopped));
  @override
  bool onServiceFound(MDNSService service) {
    add(AppEventService(AppEventServiceState.Found, service));
    // Always resolve services which have been found
    return true;
  }

  @override
  void onServiceResolved(MDNSService service) =>
      add(AppEventService(AppEventServiceState.Resolved, service));
  @override
  void onServiceUpdated(MDNSService service) =>
      add(AppEventService(AppEventServiceState.Updated, service));
  @override
  void onServiceRemoved(MDNSService service) =>
      add(AppEventService(AppEventServiceState.Removed, service));

  // GETTERS AND SETTERS ////////////////////////////////////////////

  @override
  AppState get initialState => AppStateUninitialized();
}
