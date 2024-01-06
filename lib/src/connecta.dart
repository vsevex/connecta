import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:connecta/src/exception.dart';

part 'toolkit.dart';
part '_tcp.dart';
part '_tls.dart';
part 'socket.dart';

typedef OnBadCertificateCallback = bool Function(io.X509Certificate);

/// The main class of the [Connecta] package for managing socket connections.
class Connecta {
  /// Creates a new instance of [Connecta] with the provided [ConnectaToolkit].
  Connecta(this._toolkit);

  /// An instance of [ConnectaToolkit] for configuring connection parameters.
  final ConnectaToolkit _toolkit;

  /// An instance of [ConnectaSocket] for managing the socket connection.
  late ConnectaSocket _socket;

  /// A flag indicating whether the current whether the current connection is
  /// secure (TLS) or not.
  late bool _isSecure;

  /// Establishes a socket connection based on the configuration in the
  /// [ConnectaToolkit] with provided [ConnectaListener].
  ///
  /// ### Example:
  /// ```dart
  /// final connecta = Connecta(ConnectaToolkit(hostname: 'example.org'));
  /// await connecta.connect(ConnectaListener(onData: (data) => log(data)));
  /// ```
  Future<io.Socket> connect([ConnectaListener? listener]) async {
    if (_toolkit.connectionType == ConnectionType.tcp ||
        _toolkit.connectionType == ConnectionType.upgradableTcp) {
      _socket = _TCPConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tcp = _socket._createSocket(
        listener: listener,
        timeout: _toolkit.timeout,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
      );
      _isSecure = false;

      return tcp;
    } else {
      _socket = _TLSConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tls = _socket._createSocket(
        listener: listener,
        timeout: _toolkit.timeout,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
        supportedProtocols: _toolkit.supportedProtocols,
        context: _toolkit.context,
      );
      _isSecure = true;

      return tls;
    }
  }

  /// Creates a [Future] task to establish a connection based on the configured
  /// connection type in the toolkit.
  ///
  /// If the connection type is [ConnectionType.tcp] or
  /// [ConnectionType.upgradableTcp], a TCP connection task is created using
  /// [_TCPConnecta]. Otherwise, a TLS connection task is created using
  /// [_TLSConnecta].
  ///
  /// See Also:
  ///   - [Connecta]: The class containing this method.
  ///   - [_TCPConnecta]: A class representing TCP connections.
  ///   - [_TLSConnecta]: A class representing TLS connections.
  Future<io.ConnectionTask<io.Socket>> createTask([
    ConnectaListener? listener,
  ]) async {
    if (_toolkit.connectionType == ConnectionType.tcp ||
        _toolkit.connectionType == ConnectionType.upgradableTcp) {
      _socket = _TCPConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tcp = _socket._createTask(
        listener: listener,
        timeout: _toolkit.timeout,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
      );
      _isSecure = false;

      return tcp;
    } else {
      _socket = _TLSConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tls = _socket._createTask(
        listener: listener,
        timeout: _toolkit.timeout,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
        context: _toolkit.context,
      );
      _isSecure = true;

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
  ///   connectionType: ConnectionType.tls,
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
  Future<io.Socket?> upgradeConnection({
    io.Socket? upgradableSocket,
    ConnectaListener? listener,
  }) async {
    if (_toolkit.connectionType == ConnectionType.tls) {
      throw const AlreadyTLSException();
    } else if (_toolkit.connectionType == ConnectionType.tcp) {
      throw const IsNotUpgradableException();
    }

    if (!_isSecure) {
      final securedSocket = await _socket._upgradeConnection(
        timeout: _toolkit.timeout,
        listener: listener,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
        supportedProtocols: _toolkit.supportedProtocols,
        socket: upgradableSocket,
        context: _toolkit.context,
      );

      _isSecure = true;
      return securedSocket;
    }

    return null;
  }

  /// Writes data to the socket using the underlying [ConnectaSocket].
  void send(dynamic data) => _socket._write(data);

  /// Destroys current [Connecta].
  void destroy() => _socket._destroy();

  /// Getter for [io.Socket] socket variable.
  io.Socket get socket => _socket._ioSocket!;

  /// A flag indicating whether the current whether the current connection is
  /// secure (TLS) or not.
  bool get isConnectionSecure => _isSecure;
}

/// Listener methods keeper for [Connecta].
class ConnectaListener {
  const ConnectaListener({this.onData, this.onError, this.onDone});

  final void Function(List<int> data)? onData;

  /// The function type determines whether [onError] is invoked with a stack
  /// trace argument. The stack trace argument may be [StackTrace.empty] if
  /// this stream received an error without a stack trace.
  final Function(dynamic error, dynamic trace)? onError;
  final void Function()? onDone;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ConnectaListener &&
        other.onData == onData &&
        other.onError == onError &&
        other.onDone == onDone;
  }

  @override
  int get hashCode => onData.hashCode ^ onError.hashCode ^ onDone.hashCode;
}
