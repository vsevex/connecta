part of 'connecta.dart';

/// Represents a socket connection.
///
/// ### Example:
/// ```dart
/// class ConcreteConnecta extends ConnectaSocket {
///   /// ...implement socket
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
    ConnectaListener? listener,
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    List<String>? supportedProtocols,
    io.SecurityContext? context,
  });

  Future<io.ConnectionTask<io.Socket>> _createTask({
    ConnectaListener? listener,
    OnBadCertificateCallback? onBadCertificateCallback,
    io.SecurityContext? context,
  });

  /// Upgrades an existing connection to a secure connection or returns `null`.
  Future<io.Socket?> _upgradeConnection({
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    ConnectaListener? listener,
    List<String>? supportedProtocols,
    io.Socket? socket,
    io.SecurityContext? context,
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
