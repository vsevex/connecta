part of 'connecta.dart';

/// A private implementation of the [ConnectaSocket] class for `TLS` type
/// connection.
///
/// This class extends abstract [ConnectaSocket] and provides concrete
/// implementation of dedicated methods.
class _TLSConnecta extends ConnectaSocket {
  /// Creates a secure (TLS) socket connection to the specified hostname and
  /// port. If [context] is not provided, a default [io.SecurityContext] is
  /// used.
  @override
  Future<io.Socket> _createSocket({
    ConnectaListener? listener,
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    List<String>? supportedProtocols,
    io.SecurityContext? context,
  }) async {
    try {
      _ioSocket = await io.SecureSocket.connect(
        _hostname,
        _port,
        context: context,
        timeout: Duration(milliseconds: timeout),
        supportedProtocols: supportedProtocols,
        onBadCertificate: onBadCertificateCallback,
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
      throw TLSConnectionException(error);
    }
  }

  @override
  Future<io.ConnectionTask<io.Socket>> _createTask({
    ConnectaListener? listener,
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    io.SecurityContext? context,
  }) async {
    try {
      final task = await io.SecureSocket.startConnect(
        _hostname,
        _port,
        context: context,
        onBadCertificate: onBadCertificateCallback,
      ).timeout(Duration(milliseconds: timeout));

      _ioSocket = await task.socket;

      if (listener != null) {
        _handleSocket(
          onData: listener.onData,
          onError: listener.onError,
          onDone: listener.onDone,
        );
      }

      _ioSocket = await task.socket;

      return task;
    } on TimeoutException {
      throw ConnectaTimeoutException();
    } on Exception catch (error) {
      throw TLSConnectionException(error);
    }
  }

  /// Handles the subscription events for the TLS socket, forwarding data to
  /// `onData`, handling errors with `onError`.
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

  /// Writes data to the `TLS` socket. The data can be either [List<int>] or a
  /// [String]. Throws a [DataTypeException] if the data type is not supported.
  @override
  void _write(dynamic data /** List<int> || String || Map<String, dynamic>*/) {
    assert(data != null, 'data can not be null');
    if (_ioSocket == null) {
      throw NoSecureSocketException();
    }

    if (data is List<int>) {
      _ioSocket!.write(String.fromCharCodes(data));
    } else if (data is String) {
      _ioSocket!.write(data);
    } else if (data is Map) {
      _ioSocket!.write(utf8.encode(json.encode(data)));
    } else {
      throw DataTypeException(data.runtimeType);
    }
  }

  /// No need to upgrade `TLS` connection. So, return `null`.
  @override
  Future<io.Socket?> _upgradeConnection({
    required int timeout,
    OnBadCertificateCallback? onBadCertificateCallback,
    ConnectaListener? listener,
    List<String>? supportedProtocols,
    io.Socket? socket,
    io.SecurityContext? context,
  }) async =>
      null;
}
