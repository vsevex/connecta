abstract class ConnectaException implements Exception {
  const ConnectaException(this.message);

  final String message;
}

class TCPConnectionException extends ConnectaException {
  const TCPConnectionException(this.error)
      : super(
          'Connecta exception is thrown while establishing a TCP connection: $error',
        );

  final dynamic error;
}

class TLSConnectionException extends ConnectaException {
  const TLSConnectionException(this.error)
      : super(
          'Connecta exception is thrown while establishing a TLS connection: $error',
        );

  final dynamic error;
}

class DataTypeException extends ConnectaException {
  DataTypeException(this.type)
      : super('The data to be written is not in valid type: $type');

  final Type type;
}

class NoSocketAttached extends ConnectaException {
  const NoSocketAttached()
      : super(
          'To upgrade the socket you must create a Socket connection in advance',
        );
}

class NoSecureSocketException extends ConnectaException {
  NoSecureSocketException()
      : super(
          'In order to send a message to the socket, you need to upgrade the socket first',
        );
}

class SecureSocketException extends ConnectaException {
  SecureSocketException(this.error)
      : super('An error occured while Securing Socket: $error');

  final dynamic error;
}

class AlreadyTLSException extends ConnectaException {
  const AlreadyTLSException()
      : super(
          'The connection you are trying to upgrade is already a TLS connection',
        );
}

class IsNotUpgradableException extends ConnectaException {
  const IsNotUpgradableException()
      : super(
          'The connection type you have declared is not upgradable',
        );
}
