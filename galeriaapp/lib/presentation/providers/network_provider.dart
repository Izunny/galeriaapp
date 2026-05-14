import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

// Provider con estado inicial inmediato y cambios en tiempo real.
final networkStatusProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) async* {
  final connectivity = Connectivity();

  yield await connectivity.checkConnectivity();
  yield* connectivity.onConnectivityChanged;
});
