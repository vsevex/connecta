import 'dart:async';
import 'dart:io' as io;

import 'package:connecta/src/exception.dart';

part 'toolkit.dart';
part '_tcp.dart';
part '_tls.dart';
part 'socket.dart';

class Connecta {
  Connecta(this.toolkit);

  final ConnectaToolkit toolkit;
  late ConnectaSocket socket;
  late bool isSecure;

  Future<io.Socket> connect({
    void Function(List<int>)? onData,
    dynamic Function(dynamic, dynamic)? onError,
  }) async {
    if (!toolkit.startTLS) {
      socket = _TCPConnecta()
        ..initialize(hostname: toolkit.hostname, port: toolkit.port);
      final tcp = socket.createSocket(
        onData: onData,
        onError: onError,
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
      );
      isSecure = false;

      return tcp;
    } else {
      socket = _TLSConnecta()
        ..initialize(hostname: toolkit.hostname, port: toolkit.port);
      final tls = socket.createSocket(
        onData: onData,
        onError: onError,
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
      );
      isSecure = true;

      return tls;
    }
  }

  Future<io.Socket?> upgradeConnection() async {
    if (toolkit.startTLS) {
      throw const NoSocketAttached();
    }
    if (!isSecure) {
      final securedSocket = socket.upgradeConnection(
        timeout: toolkit.timeout,
        continueEmittingOnBadCert: toolkit.continueEmittingOnBadCert,
        context: toolkit.context,
      );

      return securedSocket;
    }

    return null;
  }

  void send(dynamic data) => socket.write(data);
}
