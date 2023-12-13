import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;

import 'package:connecta/src/exception.dart';

part 'toolkit.dart';
part '_tcp.dart';
part '_tls.dart';
part 'socket.dart';

typedef OnBadCertificateCallback = bool Function(io.X509Certificate);

class Connecta {
  Connecta(this._toolkit);

  final ConnectaToolkit _toolkit;
  late ConnectaSocket _socket;
  late bool _isSecure;

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

  Future<io.ConnectionTask<io.Socket>> createTask([
    ConnectaListener? listener,
  ]) async {
    if (_toolkit.connectionType == ConnectionType.tcp ||
        _toolkit.connectionType == ConnectionType.upgradableTcp) {
      _socket = _TCPConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tcp = _socket._createTask(
        listener: listener,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
      );
      _isSecure = false;

      return tcp;
    } else {
      _socket = _TLSConnecta()
        .._initialize(hostname: _toolkit._hostname, port: _toolkit._port);
      final tls = _socket._createTask(
        listener: listener,
        onBadCertificateCallback: _toolkit.onBadCertificateCallback,
        context: _toolkit.context,
      );
      _isSecure = true;

      return tls;
    }
  }

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

  void send(dynamic data) => _socket._write(data);

  void destroy() => _socket._destroy();

  io.Socket get socket => _socket._ioSocket!;

  bool get isConnectionSecure => _isSecure;
}

class ConnectaListener {
  const ConnectaListener({this.onData, this.onError, this.onDone});

  final void Function(List<int> data)? onData;
  final Function(dynamic error, dynamic trace)? onError;
  final void Function()? onDone;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is ConnectaListener &&
        other.onData == onData &&
        other.onError == onError &&
        other.onDone == onDone;
  }

  @override
  int get hashCode => onData.hashCode ^ onError.hashCode ^ onDone.hashCode;
}
