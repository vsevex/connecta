part of 'connecta.dart';

abstract class ConnectaSocket {
  late io.Socket? ioSocket;
  late final String _hostname;
  late final int _port;
  late StreamSubscription subscription;

  void initialize({required String hostname, required int port}) {
    _hostname = hostname;
    _port = port;
  }

  Future<io.Socket> createSocket({
    void Function(List<int>)? onData,
    Function(dynamic error, dynamic trace)? onError,
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.SecurityContext? context,
  });
  Future<io.Socket?> upgradeConnection({
    required int timeout,
    required bool continueEmittingOnBadCert,
    io.Socket? socket,
    io.SecurityContext? context,
  });
  void write(dynamic data);
  void destroy() {
    if (ioSocket != null) {
      ioSocket!.destroy();
    }
    subscription.cancel();
  }
}
