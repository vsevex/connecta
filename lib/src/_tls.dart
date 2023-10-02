part of 'connecta.dart';

class _TLSConnecta extends ConnectaSocket {
  late io.SecurityContext? certificate;

  @override
  Future<io.Socket> createSocket({
    void Function(List<int> p1)? onData,
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

    return ioSocket!;
  }

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

  @override
  void write(dynamic data) {
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

  @override
  Future<io.Socket?> upgradeConnection({
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.Socket? socket,
    io.SecurityContext? context,
  }) async {
    try {
      if (ioSocket == null) {
        throw const NoSocketAttached();
      }
      subscription.pause();

      final securedSocket = await io.SecureSocket.secure(
        socket ?? ioSocket!,
        context: context,
        onBadCertificate: (certificate) => continueEmittingOnBadCert,
      );

      subscription.resume();

      return securedSocket;
    } catch (error) {
      throw SecureSocketException(error);
    }
  }
}
