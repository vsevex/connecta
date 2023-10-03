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
  late io.Socket? ioSocket;

  /// The hostname to connect to.
  late final String _hostname;

  /// The port to connect to.
  late final int _port;

  /// A stream subscription for managing socket events.
  late StreamSubscription subscription;

  /// Initializes the socket with the specified [hostname] and [port].
  void initialize({required String hostname, required int port}) {
    _hostname = hostname;
    _port = port;
  }

  /// Creates a new socket connection with the provided parameters.
  Future<io.Socket> createSocket({
    void Function(List<int>)? onData,
    Function(dynamic error, dynamic trace)? onError,
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.SecurityContext? context,
  });

  /// Upgrades an existing connection to a secure connection or returns `null`.
  Future<io.Socket?> upgradeConnection({
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.Socket? socket,
    io.SecurityContext? context,
  });

  /// Writes data to the socket.
  void write(dynamic data);

  /// Destroys the socket connection and cancels the stream subscription.
  void destroy() {
    if (ioSocket != null) {
      ioSocket!.destroy();
    }
    subscription.cancel();
  }
}
