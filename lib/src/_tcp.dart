part of 'connecta.dart';

/// A private implementation of the [ConnectaSocket] class for `TCP` type
/// connection.
///
/// This class extends abstract [ConnectaSocket] and provides concrete
/// implementation of dedicated methods.
class _TCPConnecta extends ConnectaSocket {
  /// Creates a `TCP` socket connection to the specified hostname and port.
  @override
  Future<io.Socket> _createSocket({
    ConnectaListener? listener,
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    List<String>? supportedProtocols,
    io.SecurityContext? context,
  }) async {
    try {
      _ioSocket = await io.Socket.connect(
        _hostname,
        _port,
        timeout: Duration(milliseconds: timeout),
      );

      if (listener != null) {
        _handleSocket(
          onData: listener.onData,
          onError: listener.onError,
          onDone: listener.onDone,
        );
      }

      return _ioSocket!;
    } on Exception catch (error) {
      throw TCPConnectionException(error);
    }
  }

  @override
  Future<io.ConnectionTask<io.Socket>> _createTask({
    ConnectaListener? listener,
    OnBadCertificateCallback? onBadCertificateCallback,
    io.SecurityContext? context,
  }) async {
    try {
      final task = await io.Socket.startConnect(
        _hostname,
        _port,
      );

      _ioSocket = await task.socket;

      if (listener != null) {
        _handleSocket(
          onData: listener.onData,
          onError: listener.onError,
          onDone: listener.onDone,
        );
      }

      return task;
    } on Exception catch (error) {
      throw TCPConnectionException(error);
    }
  }

  /// Handles the subscription events for the `TCP` socket, forwarding data to
  /// `onData`, handling errors with `onError` and destroying the socket on
  /// completion.
  void _handleSocket({
    void Function(List<int> data)? onData,
    Function(dynamic error, dynamic trace)? onError,
    void Function()? onDone,
  }) {
    _subscription = _ioSocket!.listen(
      onData,
      onError: onError,
      onDone: () {
        onDone?.call();
        _ioSocket!.destroy();
      },
      cancelOnError: true,
    );
  }

  /// Writes data to socket
  ///
  /// ### Example:
  /// ```dart
  /// final socket = _TCPConnecta();
  /// socket.write('hert!'); /// sends "hert!" over the socket.
  /// ```
  @override
  void _write(dynamic data) {
    assert(data != null, 'data can not be null');

    if (data is List<int>) {
      _ioSocket!.write(String.fromCharCodes(data));
    } else if (data is String) {
      _ioSocket!.write(data);
    } else {
      throw DataTypeException(data.runtimeType);
    }
  }

  /// Upgrades an existing `TCP` connection to a secure connection using TLS.
  ///
  /// Pauses the subscription during the upgrade process.
  @override
  Future<io.Socket?> _upgradeConnection({
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    ConnectaListener? listener,
    List<String>? supportedProtocols,
    io.Socket? socket,
    io.SecurityContext? context,
  }) async {
    if (_ioSocket == null) {
      throw const NoSocketAttached();
    }

    try {
      _subscription.pause();

      _ioSocket = await io.SecureSocket.secure(
        socket ?? _ioSocket!,
        context: context,
        onBadCertificate: onBadCertificateCallback,
        supportedProtocols: supportedProtocols,
      );

      _subscription.resume();

      if (listener != null) {
        _handleSocket(
          onData: listener.onData,
          onError: listener.onError,
          onDone: listener.onDone,
        );
      }

      return _ioSocket;
    } catch (error) {
      throw SecureSocketException(error);
    }
  }
}
