part of 'connecta.dart';

enum ConnectionType {
  tcp,
  upgradableTcp,
  tls,
}

/// A utility class for configuring and managing connection parameters for the
/// [Connecta].
///
/// ### Example:
/// ```dart
/// final toolkit = ConnectaToolkit(
///   hostname: 'localhost',
///   port: 443,
///   connectionType: ConnectionType.tls,
/// );
/// ```
class ConnectaToolkit {
  /// Creates a new instance of `ConnectaToolkit` with the specified
  /// configuration options.
  ConnectaToolkit({
    required String hostname,
    int port = 80,
    this.timeout = 3000,
    this.connectionType = ConnectionType.tcp,
    this.supportedProtocols,
    this.onBadCertificateCallback,
    this.context,
  }) : assert(hostname.isNotEmpty, 'Hostname can not be empty') {
    _hostname = hostname;
    _port = port;
  }

  /// The hostname to connect to.
  late final String _hostname;

  /// The port to connect to (defaults to 8080).
  late final int _port;

  /// The connection timeout in milliseconds (defaults to 3000).
  final int timeout;

  /// Indicates to the type of connection. It can be tls or tcp initially or
  /// upgradable tcp for later upgrade.
  final ConnectionType connectionType;

  /// An optional list of protocols (in decreasing order of preference) to use
  /// during the ALPN protocol negotiation with the server.
  final List<String>? supportedProtocols;

  /// Dart's built-in method that helps to indicate to continue on bad
  /// certificate or not.
  OnBadCertificateCallback? onBadCertificateCallback;

  /// An optional [io.SecurityContext] for `TLS` configuration.
  io.SecurityContext? context;

  @override
  String toString() => '''Connecta: $_hostname:$_port''';
}
