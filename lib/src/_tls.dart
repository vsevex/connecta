part of 'connecta.dart';

/// A private implementation of the [ConnectaSocket] class for `TLS` type
/// connection.
///
/// This class extends abstract [ConnectaSocket] and provides concrete
/// implementation of dedicated methods.
class _TLSConnecta extends ConnectaSocket {
  /// An optional [io.SecurityContext] for certificate-related configurations.
  late io.SecurityContext? certificate;

  /// Creates a secure (TLS) socket connection to the specified hostname and
  /// port. If [context] is not provided, a default [io.SecurityContext] is
  /// used.
  @override
  Future<io.Socket> createSocket({
    void Function(List<int> data)? onData,
    Function(dynamic error, dynamic trace)? onError,
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.SecurityContext? context,
  }) async {
    if (context == null) {
      certificate = io.SecurityContext.defaultContext;
    }

    ioSocket = await io.SecureSocket.connect(
      _hostname,
      _port,
      context: context,
      timeout: Duration(milliseconds: timeout),
      onBadCertificate: (cert) => continueEmittingOnBadCert,
    );

    _handleSocket(onData: onData, onError: onError);

    return ioSocket!;
  }

  /// Handles the subscription events for the TLS socket, forwarding data to
  /// `onData`, handling errors with `onError`.
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

  /// Static method to build a [io.SecurityContext] using the provided
  /// certificate and key paths. Throws a [BuildSocketContextException] if
  /// there is an error building the context.
  static io.SecurityContext buildCertificate({
    required String certificatePath,
    required String keyPath,
  }) {
    try {
      return io.SecurityContext(withTrustedRoots: true)
        ..useCertificateChain(certificatePath)
        ..usePrivateKey(keyPath);
    } on Exception {
      throw const BuildSocketContextException();
    }
  }

  /// Writes data to the `TLS` socket. The data can be either [List<int>] or a
  /// [String]. Throws a [DataTypeException] if the data type is not supported.
  @override
  void write(dynamic data /** List<int> || String */) {
    assert(data != null, 'data can not be null');
    if (ioSocket == null) {
      throw NoSecureSocketException();
    }

    if (data is List<int>) {
      ioSocket!.write(String.fromCharCodes(data));
    } else if (data is String) {
      ioSocket!.write(data);
    } else {
      throw DataTypeException(data.runtimeType);
    }
  }

  /// No need to upgrade `TLS` connection. So, return `null`.
  @override
  Future<io.Socket?> upgradeConnection({
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.Socket? socket,
    io.SecurityContext? context,
  }) async =>
      null;
}
