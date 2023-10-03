import 'dart:async';
import 'dart:io' as io;

import 'package:connecta/src/exception.dart';

part 'toolkit.dart';
part '_tcp.dart';
part '_tls.dart';
part 'socket.dart';

/// The main class of the [Connecta] package for managing socket connections.
class Connecta {
  /// Creates a new instance of [Connecta] with the provided [ConnectaToolkit].
  Connecta(this.toolkit);

  /// An instance of [ConnectaToolkit] for configuring connection parameters.
  final ConnectaToolkit toolkit;

  /// An instance of [ConnectaSocket] for managing the socket connection.
  late ConnectaSocket socket;

  /// A flag indicating whether the current whether the current connection is
  /// secure (TLS) or not.
  late bool isSecure;

  /// Establishes a socket connection based on the configuration in the
  /// [ConnectaToolkit].
  ///
  /// ### Example:
  /// ```dart
  /// final connecta = Connecta(ConnectaToolkit());
  /// await connecta.connect(onData: (data) => log(data));
  /// ```
  Future<io.Socket> connect({
    void Function(List<int>)? onData,
    dynamic Function(dynamic, dynamic)? onError,
  }) async {
    if (!toolkit.startTLS) {
      socket = _TCPConnecta()
        ..initialize(hostname: toolkit.hostname, port: toolkit.port);
      final tcp = socket.createSocket(
        onData: onData,
        onError: onError,
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
      );
      isSecure = false;

      return tcp;
    } else {
      socket = _TLSConnecta()
        ..initialize(hostname: toolkit.hostname, port: toolkit.port);
      final tls = socket.createSocket(
        onData: onData,
        onError: onError,
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
      );
      isSecure = true;

      return tls;
    }
  }

  /// Upgrades the current connection to a secure (TLS) connection.
  ///
  /// ### Example:
  /// ```dart
  /// ConnectaToolkit myToolkit = ConnectaToolkit(
  ///   hostname: 'example.com',
  ///   port: 443,
  ///   startTLS: true,
  ///   certificatePath: '/path/to/certificate.pem',
  ///   keyPath: '/path/to/key.pem',
  /// );
  ///
  /// Connecta myConnecta = Connecta(myToolkit);
  ///
  /// try {
  ///   await myConnecta.connect(
  ///     onData: (data) {
  ///       // Handle incoming data
  ///     },
  ///     onError: (error, trace) {
  ///       // Handle socket error
  ///     },
  ///   );
  ///
  ///   // Upgrade the connection to secure if needed
  ///   await myConnecta.upgradeConnection();
  ///
  ///   // Send data to the socket
  ///   myConnecta.send('hert!');
  /// } catch (e) {
  ///   print('Connecta Exception: $e');
  ///   // Handle exceptions appropriately
  /// }
  /// ```
  Future<io.Socket?> upgradeConnection() async {
    if (toolkit.startTLS) {
      throw const NoSocketAttached();
    }

    if (!isSecure) {
      final securedSocket = await socket.upgradeConnection(
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
        socket: socket.ioSocket,
        context: toolkit.context,
      );

      isSecure = true;
      return securedSocket;
    }

    return null;
  }

  /// Writes data to the socket using the underlying [ConnectaSocket].
  void send(dynamic data) => socket.write(data);
}
