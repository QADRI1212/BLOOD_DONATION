import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/logger_service.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final LoggerService _logger = LoggerService();
  final StreamController<bool> _connectionStatusController =
      StreamController<bool>.broadcast()..add(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get connectionStream => _connectionStatusController.stream;

  bool get isConnected => _connectionStatusController.isClosed ? true : _lastKnownValue;

  bool _lastKnownValue = true;

  Future<void> initialize() async {
    final results = await _connectivity.checkConnectivity();
    _updateConnectionStatus(results);

    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final connected = results.any(
      (result) => result != ConnectivityResult.none,
    );
    _lastKnownValue = connected;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(connected);
    }
    _logger.info('Connectivity changed: ${connected ? "Online" : "Offline"}');
  }

  Future<bool> checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    return results.any((result) => result != ConnectivityResult.none);
  }

  void dispose() {
    _subscription?.cancel();
    _connectionStatusController.close();
  }
}
