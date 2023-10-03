part of 'connecta.dart';

/// A utility class for configuring and managing connection parameters for the
/// [Connecta].
///
/// ### Example:
/// ```dart
/// final toolkit = ConnectaToolkit(
///   hostname: 'localhost',
///   port: 443,
///   startTLS: true,
///   certificatePath: '/path/to/certificate.pem',
///   keyPath: '/path/to/key.pem',
/// );
/// ```
class ConnectaToolkit {
  /// Creates a new instance of `ConnectaToolkit` with the specified
  /// configuration options.
  ConnectaToolkit({
    required this.hostname,
    this.port = 8080,
    this.timeout = 3000,
    this.startTLS = false,
    this.continueEmittingOnBadCert = true,
    this.certificatePath = '',
    this.keyPath = '',
    this.context,
  }) : assert(hostname.isNotEmpty, 'Hostname can not be empty') {
    if (context == null) {
      if (certificatePath.isNotEmpty && keyPath.isNotEmpty) {
        context = _TLSConnecta.buildCertificate(
          certificatePath: certificatePath,
          keyPath: keyPath,
        );
      } else {
        throw const InvalidCertOrKeyException();
      }
    }
  }

  /// The hostname to connect to.
  final String hostname;

  /// The port to connect to (defaults to 8080).
  final int port;

  /// The connection timeout in milliseconds (defaults to 3000).
  final int timeout;

  /// A flag indicating whether to start `TLS` (Secure) connection (defaults to
  /// false).
  final bool startTLS;

  /// A flag indicating whether to continue emitting data on a bad `TLS`
  /// certificate (defaults to true).
  final bool continueEmittingOnBadCert;

  /// The path to the certificate file for `TLS` connection (defaults to an
  /// empty string).
  final String certificatePath;

  /// The path to the key file for `TLS` connection (defaults to an empty
  /// string).
  final String keyPath;

  /// An optional [io.SecurityContext] for `TLS` configuration.
  io.SecurityContext? context;

  @override
  String toString() => '''Connecta info: $hostname:$port''';
}
