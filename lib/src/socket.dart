part of 'connecta.dart';

/// Represents a socket connection.
///
/// ### Example:
/// ```dart
/// class ConcreteConnecta extends ConnectaSocket {
///   // ...implement socket
/// }
///
/// final mySocket = ConcreteConnecta();
/// mySocket.initialize(hostname: 'localhost', port: 8080);
/// ```
abstract class ConnectaSocket {
  /// A reference to the underlying [io.Socket] object.
  late io.Socket? _ioSocket;

  /// The hostname to connect to.
  late final String _hostname;

  /// The port to connect to.
  late final int _port;

  /// A stream subscription for managing socket events.
  late StreamSubscription _subscription;

  /// Initializes the socket with the specified [hostname] and [port].
  void _initialize({required String hostname, required int port}) {
    _hostname = hostname;
    _port = port;
  }

  /// Creates a new socket connection with the provided parameters.
  Future<io.Socket> _createSocket({
    required int timeout,
    ConnectaListener? listener,
    io.SecurityContext? context,
    List<String>? supportedProtocols,
    OnBadCertificateCallback? onBadCertificateCallback,
  });

  /// Creates a new connection task that gives cancel ability to the current
  /// connection attempt.
  Future<io.ConnectionTask<io.Socket>> _createTask({
    required int timeout,
    ConnectaListener? listener,
    io.SecurityContext? context,
    List<String>? supportedProtocols,
    OnBadCertificateCallback? onBadCertificateCallback,
  });

  /// Upgrades an existing connection to a secure connection or returns `null`.
  Future<io.Socket?> _upgradeConnection({
    required int timeout,
    io.Socket? socket,
    io.SecurityContext? context,
    ConnectaListener? listener,
    List<String>? supportedProtocols,
    OnBadCertificateCallback? onBadCertificateCallback,
  });

  /// Writes data to the socket.
  void _write(dynamic data);

  /// Destroys the socket connection and cancels the stream subscription.
  void _destroy() {
    if (_ioSocket != null) {
      _ioSocket!.destroy();
    }
    _subscription.cancel();
  }
}
