part of 'connecta.dart';

/// A private implementation of the [ConnectaSocket] class for `TCP` type
/// connection.
///
/// This class extends abstract [ConnectaSocket] and provides concrete
/// implementation of dedicated methods.
class _TCPConnecta extends ConnectaSocket {
  /// Creates a `TCP` socket connection to the specified hostname and port.
  @override
  Future<io.Socket> createSocket({
    void Function(List<int> data)? onData,
    Function(dynamic error, dynamic trace)? onError,
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.SecurityContext? context,
  }) async {
    try {
      ioSocket = await io.Socket.connect(
        _hostname,
        _port,
        timeout: Duration(milliseconds: timeout),
      );

      _handleSocket(onData: onData, onError: onError);

      return ioSocket!;
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
  }) {
    subscription = ioSocket!.listen(
      onData,
      onError: onError,
      onDone: () => ioSocket!.destroy(),
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
  void write(dynamic data) {
    assert(data != null, 'data can not be null');

    if (data is List<int>) {
      ioSocket!.write(String.fromCharCodes(data));
    } else if (data is String) {
      ioSocket!.write(data);
    } else {
      throw DataTypeException(data.runtimeType);
    }
  }

  /// Upgrades an existing `TCP` connection to a secure connection using TLS.
  ///
  /// Pauses the subscription during the upgrade process.
  @override
  Future<io.Socket?> upgradeConnection({
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.Socket? socket,
    io.SecurityContext? context,
  }) async {
    if (ioSocket == null) {
      throw const NoSocketAttached();
    }

    try {
      subscription.pause();

      ioSocket = await io.SecureSocket.secure(
        socket ?? ioSocket!,
        context: context,
        onBadCertificate: (certificate) => continueEmittingOnBadCert,
      );

      subscription.resume();

      return ioSocket;
    } catch (error) {
      throw SecureSocketException(error);
    }
  }
}
