import 'dart:async';
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
        supportedProtocols: _toolkit.supportedProtocols,
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
  const ConnectaListener({
    this.onData,
    this.onError,
    this.onDone,
    this.combineWhile,
  });

  final void Function(List<int> data)? onData;

  /// The function type determines whether [onError] is invoked with a stack
  /// trace argument. The stack trace argument may be [StackTrace.empty] if
  /// this stream received an error without a stack trace.
  final Function(dynamic error, dynamic trace)? onError;
  final void Function()? onDone;

  /// Helper method to check whether continue to combine when there is a data
  /// from socket or not.
  ///
  /// This method can be provided by the user, if not provided TLS socket will
  /// check if the upcoming data length is more than 1024 bytes or not. If
  /// check returns true, then it waits until the next data stream and combines
  /// previous and current data.
  final bool Function(List<int> current)? combineWhile;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ConnectaListener &&
        other.onData == onData &&
        other.onError == onError &&
        other.onDone == onDone &&
        other.combineWhile == combineWhile;
  }

  @override
  int get hashCode =>
      onData.hashCode ^
      onError.hashCode ^
      onDone.hashCode ^
      combineWhile.hashCode;
}

/// This was created since the native [reduce] says:
/// > When this stream is done, the returned future is completed with the value
/// at that time.
///
/// The problem is that socket connections does not emits the [done] event after
/// each message but after the socket disconnection.
extension ReduceWhile<T> on Stream<T> {
  /// An extension method on the Stream class that allows you to reduce a stream
  /// of elements while applying a condition.
  ///
  /// [combine] is a required function that takes two elements of type [T] and
  /// returns a single element of type [T]. This function is used to combine the
  /// previous element with the current element.
  ///
  /// [combineWhile] is a required function that takes an element of type [T]
  /// and returns a [bool] value. This function is used to determine whether to
  /// continue reducing the stream or not.
  ///
  /// ### Example:
  /// ```dart
  /// final numbers = Stream.fromIterable([1, 2, 3, 4]);
  ///
  /// _subscription = numbers.reduceWhile(
  ///   combine: (previous, element) => previous + element,
  ///   (element) => element <= 3,
  /// );
  /// ```
  ///
  /// Combines the elements of the `numbers` stream as long as the element is
  /// less than or equal to 3. You can listen to the stream afterwards, 'cause
  /// [reduceWhile] returns [Stream] after combining elements regarding to
  /// [combine] method.
  Stream<T> reduceWhile({
    required T Function(T previous, T element) combine,
    required bool Function(T current, {T? previous}) combineWhile,
  }) async* {
    T? previous;

    await for (final element in this) {
      if (previous == null) {
        previous = element;
      } else {
        previous = combine(previous, element);
      }

      if (previous != null && !combineWhile(element, previous: previous)) {
        yield previous;
        previous = null;
      }
    }
  }
}
