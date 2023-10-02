part of 'connecta.dart';

class ConnectaToolkit {
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

  final String hostname;
  final int port;
  final int timeout;
  final bool startTLS;
  final bool continueEmittingOnBadCert;
  final String certificatePath;
  final String keyPath;
  io.SecurityContext? context;

  @override
  String toString() => '''Connecta info: $hostname:$port''';
}
