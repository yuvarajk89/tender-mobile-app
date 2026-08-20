import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/persistence/local_store.dart';

/// Entry point. [ProviderScope] is the Riverpod root that holds every provider
/// (repositories, controllers, theme). Before the app starts we load locally
/// persisted lots + stones so created data survives a restart (see
/// data/persistence/local_store.dart).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalStore.I.init();
  LocalStore.I.load();
  runApp(const ProviderScope(child: DondaDiamondApp()));
}
