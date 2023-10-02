part of 'connecta.dart';

class _TCPConnecta extends ConnectaSocket {
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
