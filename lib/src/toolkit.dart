part of 'connecta.dart';

enum ConnectionType {
  tcp,
  upgradableTcp,
  tls,
}

class ConnectaToolkit {
  ConnectaToolkit({
    required String hostname,
    int port = 8080,
    this.timeout = 3000,
    this.isTask = false,
    this.connectionType = ConnectionType.tcp,
    this.supportedProtocols,
    this.onBadCertificateCallback,
    this.context,
  }) : assert(hostname.isNotEmpty, 'Hostname can not be empty') {
    _hostname = hostname;
    _port = port;
  }

  late final String _hostname;
  late final int _port;
  final int timeout;
  final bool isTask;
  final ConnectionType connectionType;
  final List<String>? supportedProtocols;
  OnBadCertificateCallback? onBadCertificateCallback;
  io.SecurityContext? context;

  @override
  String toString() => '''Connecta: $_hostname:$_port''';
}
